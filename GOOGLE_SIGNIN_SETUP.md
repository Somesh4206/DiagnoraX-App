# Google Sign-In Setup Guide

## Current Error: People API Not Enabled

The error you're seeing means the Google People API needs to be enabled in your Google Cloud project.

## Quick Fix (2 minutes)

### Step 1: Enable People API
Click this link (it will open directly to the API page):
```
https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=858146532130
```

### Step 2: Click "Enable API"
You'll see a blue "Enable API" button. Click it.

### Step 3: Wait 1-2 Minutes
The API takes a moment to activate.

### Step 4: Test Again
Refresh your app and click "Continue with Google" again.

---

## Complete Setup Checklist

If you still have issues after enabling the People API, make sure you've completed ALL these steps:

### ✅ Step 1: Enable People API (see above)

### ✅ Step 2: Configure OAuth Client
1. Go to: https://console.cloud.google.com/apis/credentials?project=diagnorax-ai
2. Click on OAuth client: `858146532130-rmnpqqbtkcr4k3thlaho5drr252kkvq9`
3. Add **Authorized JavaScript origins**:
   ```
   http://localhost
   http://localhost:58610
   ```
4. Add **Authorized redirect URIs**:
   ```
   http://localhost/__/auth/handler
   http://localhost:58610/__/auth/handler
   ```
5. Click "Save"

### ✅ Step 3: Wait for Propagation
Wait 5-10 minutes for changes to propagate through Google's systems.

### ✅ Step 4: Clear Browser Cache
- Press `Ctrl + Shift + Delete` (Windows) or `Cmd + Shift + Delete` (Mac)
- Select "Cached images and files"
- Click "Clear data"

### ✅ Step 5: Test Google Sign-In
1. Refresh your app
2. Click "Continue with Google"
3. Select your Google account
4. You should be signed in!

---

## Alternative: Use Email/Password Login

If you don't want to configure Google Sign-In right now, Email/Password login is fully working:

1. Click "Don't have an account? Register"
2. Enter your name, email, and password
3. Click "Register"

---

## Troubleshooting

### Error: "People API has not been used"
→ Follow Step 1 above to enable the API

### Error: "401: invalid_client"
→ Follow Step 2 above to configure OAuth origins

### Error: "Access blocked: This app's request is invalid"
→ Make sure you added BOTH JavaScript origins AND redirect URIs in Step 2

### Still not working?
1. Make sure you're logged into the correct Google account
2. Check that you're in the right project (diagnorax-ai)
3. Wait the full 5-10 minutes after making changes
4. Try in an incognito/private window

---

## Current Configuration

### Firebase Project
- Project ID: diagnorax-ai
- Project Number: 858146532130

### OAuth Client ID
```
858146532130-rmnpqqbtkcr4k3thlaho5drr252kkvq9.apps.googleusercontent.com
```

### Required APIs
- ✅ Firebase Authentication API
- ⚠️ Google People API (needs to be enabled)

---

## Quick Links

- Enable People API: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=858146532130
- OAuth Credentials: https://console.cloud.google.com/apis/credentials?project=diagnorax-ai
- Firebase Console: https://console.firebase.google.com/project/diagnorax-ai

---

The app will show you helpful error messages if something is not configured correctly!

