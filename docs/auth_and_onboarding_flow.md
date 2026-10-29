# Auth and Driver Onboarding Flow (OTP)

This document defines the authenticated driver registration flow and the auth contract it depends on. The driver verifies a phone number with an OTP before entering registration. The app then sends the access token with every onboarding and upload API request. The phone number comes from the authenticated user and is not sent again in onboarding requests.

## End-to-end flow

1. The user selects Passenger or Driver.
2. The user enters a phone number and requests an OTP.
3. The user verifies the OTP.
4. The backend returns an access token, a refresh token, and the user, including the user's role and status.
5. The app routes the user according to the role and status below.
6. For a driver with an incomplete application, the app saves each registration step independently and resumes at the first incomplete step.
7. After all required documents are saved and the application is submitted, the driver waits for admin review.

## Statuses and app routing

The `status` value returned on OTP verification and by `GET /users/me` is authoritative. For drivers, use the same lifecycle values in `GET /drivers/me/status`. Do not return legacy driver values such as `draft`, `pending`, or `under_review`.

| Role | Status | App destination and access |
|---|---|---|
| Passenger | `needs_profile` | Passenger profile registration. |
| Passenger | `active` | Passenger home. |
| Driver | `needs_profile` | Driver registration steps 1 and 2. |
| Driver | `needs_documents` | Driver registration step 3. |
| Driver | `pending_review` | Waiting screen. The driver cannot go online. |
| Driver | `approved` | Driver dashboard. The driver can go online. |
| Driver | `rejected` | Rejection screen with the rejection reason. The driver cannot go online. |
| Any role | `suspended` | Blocked screen with a support message. The account cannot use protected app features. |

The driver status progression is:

```text
needs_profile -> needs_documents -> pending_review -> approved
                                                \-> rejected
```

An admin may set an account to `suspended`. A driver's online/status endpoint must independently reject requests unless the driver is `approved`.

## OTP authentication endpoints

All endpoints are relative to `/api/v1`.

### `POST /auth/otp/request` — public

Request an OTP for the selected role.

Request:

```json
{
  "phone": "+201012345678",
  "role": "driver"
}
```

Requirements:

- Normalize Egyptian phone numbers on the server. Accept local prefixes `010`, `011`, `012`, and `015`; store the normalized number as `+201XXXXXXXXX`.
- One phone number belongs to one role. If it already belongs to the other role, return `409 ROLE_MISMATCH`.
- If the account is suspended, return `403 ACCOUNT_SUSPENDED`.
- Generate a six-digit code valid for five minutes and store only its hash.
- Send the code by SMS. Suggested Arabic message: `كود الدخول لتطبيق سوزوكي: 123456. صالح لمدة 5 دقائق. لا تشاركه مع أحد.`
- Allow resend after 60 seconds. Limit to 3 sends per phone per 15 minutes and 10 per IP per hour. Return `429 OTP_RATE_LIMIT` with `retry_after_seconds` when limited.

Success response (`200`):

```json
{
  "data": {
    "expires_in": 300,
    "resend_after": 60
  }
}
```

### `POST /auth/otp/verify` — public

Request:

```json
{
  "phone": "+201012345678",
  "code": "123456",
  "device_id": "device-identifier"
}
```

The requested role is associated with the OTP request created by `/auth/otp/request`. If no user exists for the phone, create one with that role and status `needs_profile`. Set `phone_verified_at` on first successful verification and update `last_login_at` on successful login.

Allow no more than five incorrect attempts per OTP. Return `400 OTP_INVALID` with `attempts_left` for an incorrect code, `400 OTP_EXPIRED` for an expired code, and `429 OTP_TOO_MANY_ATTEMPTS` when the attempt limit is reached.

Success response (`200`):

```json
{
  "data": {
    "access_token": "<access-token>",
    "refresh_token": "<refresh-token>",
    "is_new_user": true,
    "user": {
      "id": "user-id",
      "phone": "+201012345678",
      "role": "driver",
      "full_name": null,
      "avatar_url": null,
      "status": "needs_profile"
    }
  }
}
```

`full_name` and `avatar_url` may be null until profile information has been saved.

### `POST /auth/refresh` — public

Request:

```json
{
  "refresh_token": "<refresh-token>"
}
```

Return a new access token and a rotated refresh token. Reuse of a rotated refresh token returns `401 REFRESH_INVALID` and revokes that device's tokens.

### `POST /auth/logout` — authenticated

Revoke the submitted refresh token:

```json
{
  "refresh_token": "<refresh-token>"
}
```

### `GET /users/me` — authenticated

Return the current user fields from the OTP response, with the latest role and status. The app reads this endpoint when restoring a session and after each successfully saved registration step to refresh the signed-in user's state. It reads `GET /drivers/me/status` to resume at the first incomplete step and retrieve document review details.

## Authenticated driver registration

Every endpoint in this section requires `Authorization: Bearer <access_token>` and a user whose role is `driver`. Passenger tokens must receive `403` on driver endpoints. The app saves steps independently; successful writes must be durable so a driver can resume later.

The app's current API paths are listed below. They are relative to `/api/v1`.

### Image uploads

There is no presigned upload endpoint. The app sends image files directly to the driver registration endpoints as `multipart/form-data`. Enforce the upload size limit and validate image content on the server.

### Step 1 — personal information

`PUT /drivers/register/step1`

Request (`multipart/form-data`): text fields `full_name`, `national_id`, `birth_date` (`YYYY-MM-DD`), and `gender` (`male` or `female`); file field `avatar`.

Requirements:

- `full_name`: required.
- `national_id`: required, exactly 14 digits, unique across drivers. Return `409 NATIONAL_ID_ALREADY_REGISTERED` for a duplicate.
- `birth_date`: required valid date in `YYYY-MM-DD` format. The driver must be at least 18. Calculate age from this date; do not store a separate age value.
- `gender`: required; `male` or `female`.
- `avatar`: required profile photo file.
- `district_id`: optional. The approved design does not collect a district.
- Do not accept or store a phone number in this payload. Use the signed-in user's phone.

### Step 2 — vehicle information

`PUT /drivers/register/step2`

Request:

```json
{
  "plate_numbers": "2845",
  "plate_letters": "ق ن ص",
  "model": "Suzuki Every",
  "color": "أبيض"
}
```

Requirements:

- `plate_numbers`: required, 1 to 4 digits.
- `plate_letters`: required, 2 or 3 Arabic letters.
- `model`: required.
- `color`: required; one of `أبيض`, `أسود`, `فضي`, `رمادي`, `أزرق`, `أحمر`, `أخضر`, `بيج`, `ذهبي`, `أخرى`.
- The pair `plate_numbers` + `plate_letters` must be unique. Return `409 PLATE_ALREADY_REGISTERED` for a duplicate.
- Vehicle year is optional and is not collected in the approved design.
- Seats are always 7 and are set by the server.

After steps 1 and 2 are both saved, set the driver's status to `needs_documents`.

### Step 3 — required documents

`PUT /drivers/register/step3`

The app sends one `multipart/form-data` request containing all eight files. File fields are `documents[national_id_front]`, `documents[national_id_back]`, `documents[driving_license]`, `documents[vehicle_license]`, `documents[criminal_record]`, `documents[vehicle_front]`, `documents[vehicle_rear]`, and `documents[vehicle_interior]`.

The accepted document types are exactly: `national_id_front`, `national_id_back`, `driving_license`, `vehicle_license`, `criminal_record`, `vehicle_front`, `vehicle_rear`, and `vehicle_interior`. National ID front and back remain separate document records.

After accepting step 3, validate that steps 1 and 2 are complete, all eight required files are present, and the driver has no already-submitted active application. On success, set status to `pending_review` and record `submitted_at`. The driver cannot go online while pending review.

### Replace a rejected document

`POST /drivers/me/documents/{type}` accepts the replacement as a multipart file field named `file`. `{type}` must be one of the accepted document types listed above. The replacement returns the application to `pending_review` after the required rejected files have been replaced.

### Get verification status and resume point

`GET /drivers/me/status`

Return the current status and enough information for the app to show progress and resume at the first incomplete step:

```json
{
  "data": {
    "status": "needs_documents",
    "message": null,
    "submitted_at": null,
    "rejection_reason": null,
    "completed_steps": [1, 2],
    "documents": [
      { "type": "national_id_front", "status": "missing", "reject_reason": null },
      { "type": "national_id_back", "status": "missing", "reject_reason": null },
      { "type": "driving_license", "status": "missing", "reject_reason": null },
      { "type": "vehicle_license", "status": "missing", "reject_reason": null },
      { "type": "criminal_record", "status": "missing", "reject_reason": null },
      { "type": "vehicle_front", "status": "missing", "reject_reason": null },
      { "type": "vehicle_rear", "status": "missing", "reject_reason": null },
      { "type": "vehicle_interior", "status": "missing", "reject_reason": null }
    ]
  }
}
```

Return one record per required document type, with status `missing`, `uploaded`, `approved`, or `rejected`, plus optional `reject_reason`. For review states, include the user-facing `message`, `submitted_at`, and `rejection_reason` where applicable. The driver status here must match the `status` returned by OTP verification and `GET /users/me`.

## Admin status changes

- A new driver starts at `needs_profile`.
- Saving steps 1 and 2 moves the driver to `needs_documents`.
- Submitting all eight required documents moves the driver to `pending_review`.
- Admin review moves the driver to `approved` or `rejected`.
- Admin may set any account to `suspended`.
- Only `approved` drivers may use driver features that require approval, including going online.

## Common API rules

- Base path: `/api/v1`.
- Requests and successful responses use JSON. Success payloads are wrapped in `{ "data": ... }`.
- Send `Authorization: Bearer <access_token>` on every endpoint except the public OTP request, OTP verify, and token refresh endpoints.
- Access tokens expire after 15 minutes. Refresh tokens expire after 30 days and rotate on refresh.
- Errors use `{ "error": { "code": "STABLE_CODE", "message_ar": "رسالة للمستخدم", "fields": {} } }`. `code` is a stable English constant; show `message_ar` to the user.
- Enforce role and driver status checks server-side, regardless of the screen currently shown by the app.

## Suggested auth tables

- `users`: `id`, `phone` (unique), `role` (`passenger`, `driver`, `admin`), `status`, `full_name`, avatar/media reference, `gender`, `phone_verified_at`, `last_login_at`, `created_at`, `deleted_at`.
- `otp_requests`: `id`, `phone`, `code_hash`, `expires_at`, `attempts`, `verified_at`, `ip`, `device_id`, and the requested role.
- `refresh_tokens`: `id`, `user_id`, `token_hash` (unique), `device_id`, `expires_at`, `revoked_at`, `replaced_by`.
- Driver onboarding data should persist personal information, vehicle information, document file keys and review status, submission time, and rejection reason, associated with the authenticated driver.

## Development OTP

In non-production environments, accept the fixed code `123456` for every phone so the Flutter team can test without SMS. Never enable this behavior in production.

## Related requirements

- Passenger Registration, Backend Requirements.
- Driver Registration, Laravel Backend Requirements.
