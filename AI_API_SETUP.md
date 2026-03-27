# AI API Configuration Guide

## Overview

DiagnoraX AI now supports **two AI providers** with automatic fallback:

1. **Gemini API** (Primary) - Google's AI with image analysis support
2. **Groq API** (Fallback) - Fast inference when Gemini hits rate limits

## Current Configuration

Your `.env` file is already configured with both API keys:

```env
GEMINI_API_KEY=AIzaSyBw-LSME1UNfMbC_WkxPgJgyo0yJsutUQ8
GROQ_API_KEY=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
```

✅ Both keys are active and ready to use!

## How It Works

### Automatic Fallback System

1. **Primary**: App tries Gemini API first
2. **Fallback**: If Gemini quota exceeded (429/RESOURCE_EXHAUSTED), automatically switches to Groq
3. **Seamless**: Users won't notice the switch - it happens automatically

### API Comparison

| Feature | Gemini | Groq |
|---------|--------|------|
| Text Analysis | ✅ Yes | ✅ Yes |
| Image Analysis | ✅ Yes | ❌ No |
| Rate Limits | 15/min, 1500/day | 30/min, 14400/day |
| Model | gemini-2.0-flash | llama-3.3-70b-versatile |
| Speed | Fast | Very Fast |
| Cost | Free | Free |

### When Groq is Used

Groq automatically activates when:
- Gemini returns 429 (Too Many Requests)
- Gemini returns RESOURCE_EXHAUSTED error
- Gemini quota exceeded message

### Limitations

**Image-based features require Gemini:**
- Prescription Scanner (needs image analysis)
- Report Analyzer (needs image analysis)
- Body Analyzer (text-only, works with both)

If Gemini quota is exceeded and you try to use image features, you'll see:
```
"Gemini API quota exceeded and Groq doesn't support image analysis.
Please wait a few minutes and try again."
```

## Rate Limits

### Gemini Free Tier
- 15 requests per minute
- 1,500 requests per day
- Resets every 24 hours

### Groq Free Tier
- 30 requests per minute
- 14,400 requests per day
- Much higher limits!

## Testing the Fallback

To test the automatic fallback:

1. Use Symptom Checker multiple times rapidly
2. When Gemini hits rate limit, you'll see: "Gemini quota exceeded, falling back to Groq..."
3. The request completes using Groq automatically
4. No user action needed!

## Error Messages

### No API Keys Configured
```
No AI API key configured. Please:
1. Visit https://aistudio.google.com/app/apikey (Gemini)
   OR https://console.groq.com/keys (Groq)
2. Create a free API key
3. Add it to your .env file
```

### Gemini Quota Exceeded (with Groq fallback)
```
[Console] Gemini quota exceeded, falling back to Groq...
[Success] Request completed using Groq
```

### Gemini Quota Exceeded (image feature, no fallback)
```
Gemini API quota exceeded and Groq doesn't support image analysis.
Please wait a few minutes and try again.
```

## Getting Your Own API Keys

### Gemini API Key (Recommended)

1. Visit: https://aistudio.google.com/app/apikey
2. Sign in with Google account
3. Click "Create API Key"
4. Copy the key
5. Add to `.env`: `GEMINI_API_KEY=your_key_here`

### Groq API Key (Optional but Recommended)

1. Visit: https://console.groq.com/keys
2. Sign up/login
3. Click "Create API Key"
4. Copy the key
5. Add to `.env`: `GROQ_API_KEY=your_key_here`

## Best Practices

1. **Use Both APIs**: Configure both for maximum reliability
2. **Monitor Usage**: Check console for "falling back to Groq" messages
3. **Wait for Reset**: If both hit limits, wait a few minutes
4. **Image Features**: Use sparingly as they only work with Gemini

## Troubleshooting

### "No AI API key configured"
→ Check your `.env` file has at least one API key

### "Gemini API error: 401"
→ Your Gemini API key is invalid, get a new one

### "Groq API error: 401"
→ Your Groq API key is invalid, get a new one

### Features not working
→ Make sure you restarted the app after adding API keys

### Image features failing
→ Gemini quota might be exceeded, wait a few minutes

## Current Status

✅ Gemini API: Configured and active
✅ Groq API: Configured and active as fallback
✅ Automatic fallback: Enabled
✅ All text-based features: Working with both APIs
✅ Image-based features: Working with Gemini only

## Support

Both APIs are completely free to use with generous rate limits. The dual-API system ensures your app keeps working even when one API hits rate limits!
