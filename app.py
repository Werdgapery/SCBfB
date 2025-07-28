import os
from flask import Flask, request, redirect
import requests
from aiogram import Bot, Dispatcher, types
import asyncio
import random
import string
from bot import bot, dp

CLIENT_ID = os.getenv("CLIENT_ID")
CLIENT_SECRET = os.getenv("CLIENT_SECRET")
REDIRECT_URI = os.getenv("REDIRECT_URI")
BOT_TOKEN = os.getenv("BOT_TOKEN")

app = Flask(__name__)

# Telegram bot setup
bot = Bot(token=BOT_TOKEN)
dp = Dispatcher(bot)

user_states = {}

@dp.message(commands=['start'])
async def start_cmd(event: types.Message):
    await event.reply("Привет! Используй /auth чтобы связать аккаунт EXBO.")

@dp.message(commands=['auth'])
async def auth_cmd(event: types.Message):
    state = ''.join(random.choices(string.ascii_letters + string.digits, k=16))
    user_states[str(event.from_user.id)] = state
    auth_url = (
        f"https://exbo.net/oauth/authorize"
        f"?client_id={CLIENT_ID}"
        f"&redirect_uri={REDIRECT_URI}"
        f"&scope="
        f"&response_type=code"
        f"&state={state}"
    )
    await event.reply(f"Авторизуйся: {auth_url}")

async def run_bot():
    await dp.start_polling(bot)

@app.route("/callback")
def oauth_callback():
    code = request.args.get("code")
    state = request.args.get("state")
    # не забудь проверить state!
    # обмен кода на токен:
    resp = requests.post("https://exbo.net/oauth/token", data={
        "client_id": CLIENT_ID,
        "client_secret": CLIENT_SECRET,
        "code": code,
        "grant_type": "authorization_code",
        "redirect_uri": REDIRECT_URI,
        "scope": ""
    })
    data = resp.json()
    access_token = data.get("access_token")
    # временно — отправь сообщение в чат (или сохрани токен)
    # здесь не хватает user_id — можно передать его через state
    return "Авторизация завершена. Можешь вернуться в Telegram."

if __name__ == "__main__":
    # запуск Telegram‑бота и Flask одновременно
    loop = asyncio.get_event_loop()
    loop.create_task(run_bot())
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 5000)))
