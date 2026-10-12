# AI Prompts Used in the App

All AI requests go through the same proxy:

- **Endpoint:** `POST https://openai-api-gamma.vercel.app/api/chat`
- **Body:** `{ "input": "<prompt text>" }`
- **Code:** `OpenAIChatService.shared.send(input:completion:)` in `NKJV Bible/App/Support/OpenAIChat/OpenAIChatService.swift`

Each prompt is sent as a single text input (no separate system / user roles).

---

## 1. Get Explanation (verse)

- **Where in the app:** Home / Reader → tap a verse → verse menu → **Get Explanation**
- **Code:** `OpenAIExplanationService.fetchExplanation(...)` in `NKJV Bible/App/Support/OpenAIChat/OpenAIExplanationService.swift`
- **Daily limit:** 1 free, then 20 credits (unlimited for Monthly / Yearly and legacy paid-app users)

```text
You are a helpful Bible study assistant. Provide a clear, faithful, and concise explanation of the following verse.

Translation: {bibleVersion}
Verse reference: {verseReference}
Verse text: {verseText}

Respond in {language} only. Do not use markdown or asterisks. Do not add a title or heading — give the explanation directly.
```

| Placeholder | Value |
|---|---|
| `{bibleVersion}` | Bible translation name shown in the app |
| `{verseReference}` | e.g. `John 3:16` |
| `{verseText}` | Full text of the selected verse |
| `{language}` | `language_code` saved in the app (defaults to `en`) |

---

## 2. Chapter Summary

- **Where in the app:** Reader → end of a chapter → **Summary** button
- **Code:** `OpenAIExplanationService.fetchChapterSummary(...)` in `NKJV Bible/App/Support/OpenAIChat/OpenAIExplanationService.swift`
- **Daily limit:** 1 free, then 20 credits (unlimited for Monthly / Yearly and legacy paid-app users)

```text
You are a helpful Bible study assistant. Provide a clear, faithful, and concise summary of the following chapter.

Translation: {bibleVersion}
Chapter: {chapterReference}
Chapter text: {chapterText}

Respond in {language} only. Do not use markdown or asterisks. Do not add a title or heading — give the summary directly.
```

| Placeholder | Value |
|---|---|
| `{bibleVersion}` | Bible translation name shown in the app |
| `{chapterReference}` | e.g. `John 3` |
| `{chapterText}` | Full text of the chapter |
| `{language}` | `language_code` saved in the app (defaults to `en`) |

---

## 3. AI Chat

- **Where in the app:** Settings → **AI Chat**
- **Code:** `AIChatViewController.buildInput(for:)` in `NKJV Bible/App/Controller/AIChat/AIChatViewController.swift`
- **Daily limit:** 3 free messages, then 20 credits per message (unlimited for Monthly / Yearly and legacy paid-app users)

```text
You are a helpful Bible study assistant in the {APPNAME} app. Give clear, faithful, and concise answers. Do not use markdown or asterisks.
Conversation so far:
User: {earlier user message}
Assistant: {earlier assistant reply}
...
User: {latest user message}
```

- `{APPNAME}` comes from `AppConstants.swift`.
- "Conversation so far" is only added when there is earlier history, and includes at most the **last 8 messages**.

### Suggestion chips (sent as the user's message when tapped)

**Starter suggestions** (3 random shown on an empty chat):

- Explain John 3:16
- What is grace?
- Help me study Psalms
- How can I grow in faith?
- What does Romans 8:28 mean?
- Suggest a verse for anxiety

**Follow-up suggestions** (3 random, chosen from the last question and answer):

| When the conversation mentions | Chips |
|---|---|
| A verse reference, e.g. `John 3:16` | Explain {verse} in simple words · What is the main message of {verse}? · Show verses related to {verse} · How does {verse} apply to daily life? · Who is speaking in {verse}? |
| grace / kasih karunia | Where else is grace taught? · How is grace different from mercy? · Give a short prayer about grace |
| psalm / mazmur | Help me study Psalm 23 · What makes Psalms special? · Suggest a comforting Psalm |
| pray / prayer / doa | Write a short prayer from this · How should I pray about this? · Give me a prayer for today |
| faith / iman | How can I strengthen my faith? · Show verses about trusting God · What does faith look like in practice? |
| love / kasih | Where does the Bible define love? · How can I love others better? · Show verses about God's love |
| Always available | Put this in simpler words · Give related Bible verses · How can I apply this today? · What is the key takeaway here? · Compare this with another passage · Help me memorize the main idea |

---

## 4. Open Chat (not reachable in the app)

- **Code:** `OpenChatViewController` / `OpenChatService` (`NKJV Bible/App/Support/OpenChat/OpenChatService.swift`)
- **Endpoint:** `POST https://all-model-api.vercel.app/` with `{ "input": "<user text>", "model": "<model id>" }`; models list from `https://ai-model-api-seven.vercel.app/api/ai/models`
- **Prompt:** none — sends the user's raw text only.
- `openOpenChat()` in Settings exists but nothing calls it, so users cannot open this screen.

---

## Not AI-generated

These use fixed templates built inside the app (no AI prompt):

- **Challenge Hub / Quiz** questions (Quick Quiz, Fill in the Verse, True or False, Verse Match, Word Search) — `ChallengeHub/ChallengeGameContent.swift`
- **Create Challenge (VerseDeep)** questions — `ChallengeHub/VerseDeep/ChallengeVerseDeepPlayChrome.swift`, sent to `https://api.versedeep.com/api/challenges` for sharing only
