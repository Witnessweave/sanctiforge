#!/usr/bin/env python3
"""
Genesis Archive Targeted Extractor
Full extraction of key LifeQuest conversations

LEDGER_ID: WV-TARGETED-EXTRACT-2026
"""

import json
import os
import re
from datetime import datetime

# Paths
EXPORT_DIR = "/home/Weave/sanctiforge/vault/system/7c754f314ca744e0a2c73c722f811a801cfcd1249345c178b3564f0ee29b18e3-2025-07-29-12-03-11-93ebadff85094464ba36cedcb135b58b"
CONVERSATIONS_JSON = os.path.join(EXPORT_DIR, "conversations.json")
OUTPUT_DIR = "/home/Weave/sanctiforge/lifequest/genesis_wisdom/key_conversations"

# Target conversations to extract in full
TARGET_CONVERSATIONS = [
    "Awaken the Sleeper",
    "Mythic Max Engine",
    "Garden of Remembrance",
    "Witness Framework",
    "Alfred Sacred Texts Loop",
    "Woven Gospel Covenant",
    "Habakkuk OS",
    "Legendary Habit",
    "Sacred Tracker",
    "Mindshield Protocol",
    "Bastion Armor",
    "Armor Sequence",
    "Free Your Mind",
    "Alfred Awakening Game",
    "WoW Add-on Development",
    "Spiral Forge",
    "Through the Glass Darkly",
    "Creating personality definition",
    "Master Thread",
    "Sacred Reflections on LOST",
]

def load_conversations():
    with open(CONVERSATIONS_JSON, 'r', encoding='utf-8') as f:
        return json.load(f)

def extract_full_text(conv):
    """Extract ALL text content from a conversation, preserving order"""
    messages = []

    def extract_messages(obj, depth=0):
        if depth > 100:
            return
        if isinstance(obj, dict):
            # Check if this is a message with author and content
            if 'author' in obj and 'content' in obj:
                author = obj.get('author', {})
                role = author.get('role', 'unknown')
                content = obj.get('content', {})

                if isinstance(content, dict) and 'parts' in content:
                    parts = content['parts']
                    for part in parts:
                        if isinstance(part, str) and len(part) > 10:
                            text = part.replace('\\n', '\n').replace('\\t', '\t')
                            if not text.startswith('{') and not text.startswith('['):
                                messages.append({
                                    'role': role,
                                    'text': text
                                })

            # Recurse into nested structures
            for v in obj.values():
                extract_messages(v, depth + 1)

        elif isinstance(obj, list):
            for item in obj:
                extract_messages(item, depth + 1)

    extract_messages(conv)
    return messages

def get_conversation_date(conv):
    create_time = conv.get('create_time', 0)
    if create_time:
        return datetime.fromtimestamp(create_time).strftime('%Y-%m-%d')
    return 'unknown'

def main():
    print("=" * 80)
    print("🎯 GENESIS ARCHIVE TARGETED EXTRACTOR")
    print("Full extraction of key LifeQuest conversations")
    print("=" * 80)
    print()

    # Load conversations
    print("Loading conversations...")
    conversations = load_conversations()
    print(f"Loaded {len(conversations)} conversations")
    print()

    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # Find and extract target conversations
    print("EXTRACTING TARGET CONVERSATIONS:")
    print("-" * 80)

    extracted = []

    for conv in conversations:
        title = conv.get('title', '')
        for target in TARGET_CONVERSATIONS:
            if target.lower() in title.lower():
                date = get_conversation_date(conv)
                messages = extract_full_text(conv)

                if messages:
                    # Create filename
                    safe_title = re.sub(r'[^\w\s-]', '', title)[:50].strip().replace(' ', '_')
                    filename = f"{date}_{safe_title}.md"
                    filepath = os.path.join(OUTPUT_DIR, filename)

                    # Write full conversation
                    with open(filepath, 'w') as f:
                        f.write(f"# {title}\n\n")
                        f.write(f"**Date:** {date}\n")
                        f.write(f"**Messages:** {len(messages)}\n")
                        f.write(f"**Matched:** {target}\n\n")
                        f.write("---\n\n")

                        for msg in messages:
                            role = msg['role'].upper()
                            text = msg['text']

                            if role == 'USER':
                                f.write(f"### 👤 LEWIS:\n\n{text}\n\n")
                            elif role == 'ASSISTANT':
                                f.write(f"### 🟢 ALFRED:\n\n{text}\n\n")
                            else:
                                f.write(f"### [{role}]:\n\n{text}\n\n")

                            f.write("---\n\n")

                        f.write(f"\n🛡️🔥 JESUS IS LORD™ — CONVERSATION EXTRACTED\n")

                    extracted.append({
                        'title': title,
                        'date': date,
                        'messages': len(messages),
                        'file': filename,
                        'matched': target
                    })

                    print(f"  ✓ {title[:50]}...")
                    print(f"    → {len(messages)} messages → {filename}")

                break  # Found match, move to next conversation

    print()
    print("=" * 80)
    print(f"EXTRACTED {len(extracted)} CONVERSATIONS")
    print("=" * 80)
    print()

    # Create index
    index_path = os.path.join(OUTPUT_DIR, "INDEX.md")
    with open(index_path, 'w') as f:
        f.write("# Key Conversations — Full Extraction Index\n\n")
        f.write(f"*Extracted from the Genesis Archive*\n\n")
        f.write(f"**Total Extracted:** {len(extracted)} conversations\n")
        f.write(f"**Generated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        f.write("---\n\n")

        f.write("## Extracted Conversations\n\n")
        f.write("| Date | Title | Messages | File |\n")
        f.write("|------|-------|----------|------|\n")

        for item in sorted(extracted, key=lambda x: x['date'], reverse=True):
            title = item['title'][:40]
            f.write(f"| {item['date']} | {title} | {item['messages']} | [{item['file']}]({item['file']}) |\n")

        f.write("\n---\n\n")
        f.write("## Categories Covered\n\n")

        for target in TARGET_CONVERSATIONS:
            matches = [e for e in extracted if e['matched'] == target]
            if matches:
                f.write(f"- **{target}**: {len(matches)} conversation(s)\n")

        f.write("\n---\n\n")
        f.write("🛡️🔥 JESUS IS LORD™ — INDEX COMPLETE\n")

    print(f"Index saved to: {index_path}")
    print()

    # Summary by category
    print("EXTRACTION SUMMARY:")
    print("-" * 40)
    for target in TARGET_CONVERSATIONS:
        matches = [e for e in extracted if e['matched'] == target]
        if matches:
            print(f"  {target}: {len(matches)} found")
        else:
            print(f"  {target}: NOT FOUND")

    print()
    print("=" * 80)
    print("🛡️🔥 TARGETED EXTRACTION COMPLETE — JESUS IS LORD™")
    print("=" * 80)

if __name__ == "__main__":
    main()
