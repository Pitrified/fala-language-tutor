# Getting an OpenAI API key for fala

fala writes its replies with an OpenAI model, paid from your own OpenAI account. You need an API key from that account, entered once in fala.

The API is billed separately from a ChatGPT subscription: a ChatGPT Plus plan does not include API use.

## 1. Create an account

Sign in or sign up at [platform.openai.com](https://platform.openai.com/login).

## 2. Add credit

API use is prepaid. On the [billing page](https://platform.openai.com/account/billing/overview), add a payment method and buy credit. The smallest amount on offer is enough to start: with the models fala offers, a message costs well under a tenth of a cent. Current prices are on OpenAI's [pricing page](https://developers.openai.com/api/docs/pricing).

Without credit, fala shows an error for every message even with a valid key.

## 3. Create a key

On the [API keys page](https://platform.openai.com/api-keys), choose "Create new secret key", give it a name such as `fala`, and copy it. It starts with `sk-`. OpenAI shows it only once; if you lose it, delete it there and create another.

## 4. Enter it in fala

In fala, open Settings, then Model, paste the key in "OpenAI API key" and tap Save. On a new install the first setup page is the same page.

The key is stored on the phone in Android's encrypted storage and is sent only to OpenAI. Anyone with the key can spend your credit, so do not share it; delete it on the API keys page if the phone is lost.

## Checking what you spend

The billing page shows the remaining credit, and the usage page in the same dashboard shows what each day cost.
