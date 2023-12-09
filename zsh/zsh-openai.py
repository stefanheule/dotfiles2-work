#!/usr/bin/env python3

import openai
import sys
import os

def main():
    api_key = os.environ.get('OPENAI_API_KEY')
    if api_key is None:
        print('OPENAI_API_KEY is not set')
        return

    client = openai.Client(
        api_key=api_key,
    )

    buffer = sys.stdin.read()
    message=[
        {
            "role":'system',
            "content": """You are a zsh shell expert, please write a ZSH command that solves my problem.
    You should only output the completed command, no need to include any other explanation.""",
        },
        {"role": "user", "content": buffer}
    ]
    response = client.chat.completions.create(
        model="gpt-4-1106-preview",
        messages = message,
        temperature=0.2,
        max_tokens=300,
        frequency_penalty=0.0
    )
    result = response.choices[0].message.content
    result = result.replace('```zsh', '').replace('```', '').strip()
    print(result)


if __name__ == '__main__':
    main()
