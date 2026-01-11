#!/usr/bin/env python3
"""
LifeQuest Asset Builder
Extracts images and conversation content for LifeQuest from Genesis Archive

LEDGER_ID: WV-LIFEQUEST-ASSETS-2026
"""

import json
import os
import shutil
import re
from datetime import datetime

# Paths
EXPORT_DIR = "/home/Weave/sanctiforge/vault/system/7c754f314ca744e0a2c73c722f811a801cfcd1249345c178b3564f0ee29b18e3-2025-07-29-12-03-11-93ebadff85094464ba36cedcb135b58b"
USER_DIR = os.path.join(EXPORT_DIR, "user-745qRWegF0nnZToPxcd3pd7z")
CONVERSATIONS_JSON = os.path.join(EXPORT_DIR, "conversations.json")
ASSETS_DIR = "/home/Weave/sanctiforge/lifequest/assets"
CORRELATION_JSON = "/home/Weave/sanctiforge/vault/genesis/images/image_correlation.json"

# Target conversations for LifeQuest
LIFEQUEST_CONVERSATIONS = {
    "patches": [
        "🪡⚡The Spiral Forge: Patch Revival & Archive\"",
        "Sacred Patch Design",
        "Perfected art patch engine 1.0",
        "Redeemed Watchers Patch Design",
        "Woven Gospel Covenant",
        "Visible Word Patches",
        "Lost Patch Design",
        "Embroidery Patch Creation",
        "Sacred Patch Form Awakening",
    ],
    "badges": [
        "1.0Davids badge",
        "Badge symbolism summary",
        "Badge of Freedom Summary",
        "🛡️ Badge for Edward: Bearer of Steadfast Light",
        "Sacred Badge Creation",
        "Protector Badge Layout",
        "Thornwatch Badge Forge",
    ],
    "knights": [
        "Pixel art knight design",
        "Pixel character art guide",
        "Pixel character prompt",
        "Create rising character photo",
    ],
    "sacred": [
        "🕊️💻🌿 The Redeemed Code: Jesus at the Core",
        "Jesus Enters Code",
        "Sacred Code Visualization",
        "Alfred art engine",
    ]
}

def load_conversations():
    with open(CONVERSATIONS_JSON, 'r', encoding='utf-8') as f:
        return json.load(f)

def load_correlation():
    with open(CORRELATION_JSON, 'r', encoding='utf-8') as f:
        return json.load(f)

def extract_text_from_conversation(conv):
    """Extract all text content from a conversation"""
    texts = []
    conv_str = json.dumps(conv)

    # Find all text parts
    parts_matches = re.findall(r'"parts":\s*\[(.*?)\]', conv_str, re.DOTALL)
    for match in parts_matches:
        # Extract string content
        strings = re.findall(r'"([^"]{20,})"', match)
        for s in strings:
            # Unescape
            s = s.replace('\\n', '\n').replace('\\t', '\t').replace('\\"', '"')
            if len(s) > 50 and not s.startswith('{'):
                texts.append(s)

    return texts

def copy_images_for_category(category, conv_titles, correlation, all_convs):
    """Copy images for a category of conversations"""
    dest_dir = os.path.join(ASSETS_DIR, category)
    os.makedirs(dest_dir, exist_ok=True)

    copied = 0
    conv_images = correlation.get('conversation_images', {})

    for title in conv_titles:
        # Find matching conversation title (partial match)
        for conv_title, images in conv_images.items():
            if title.lower() in conv_title.lower() or conv_title.lower() in title.lower():
                for img_info in images:
                    src = os.path.join(USER_DIR, img_info['file'])
                    if os.path.exists(src):
                        # Create clean filename
                        ext = os.path.splitext(img_info['file'])[1]
                        clean_name = f"{category}_{copied:03d}{ext}"
                        dest = os.path.join(dest_dir, clean_name)
                        shutil.copy2(src, dest)
                        copied += 1

    return copied

def extract_conversation_content(conv_titles, all_convs):
    """Extract conversation content for specified titles"""
    content = []

    for conv in all_convs:
        title = conv.get('title', '')
        for target in conv_titles:
            if target.lower() in title.lower() or title.lower() in target.lower():
                texts = extract_text_from_conversation(conv)
                if texts:
                    content.append({
                        'title': title,
                        'date': datetime.fromtimestamp(conv.get('create_time', 0)).strftime('%Y-%m-%d') if conv.get('create_time') else 'unknown',
                        'texts': texts[:50]  # Limit to first 50 text blocks
                    })
                break

    return content

def generate_html_gallery():
    """Generate HTML gallery of all assets"""
    html = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>LifeQuest Asset Gallery — Genesis Archive</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link href="https://fonts.googleapis.com/css2?family=Cinzel+Decorative:wght@700&family=EB+Garamond:wght@400;600&family=IBM+Plex+Sans:wght@400;600&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #0a0b0f;
      --card: #12131a;
      --text: #e8e8ec;
      --accent: #ffcc66;
      --accent-green: #7cff7c;
      --muted: #888;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      background: var(--bg);
      color: var(--text);
      font-family: 'EB Garamond', serif;
      line-height: 1.6;
      padding: 20px;
    }
    .container { max-width: 1400px; margin: 0 auto; }

    header {
      text-align: center;
      padding: 40px 20px;
      border-bottom: 2px solid rgba(255,204,102,0.2);
      margin-bottom: 40px;
    }
    h1 {
      font-family: 'Cinzel Decorative', serif;
      color: var(--accent);
      font-size: 2.5rem;
      text-shadow: 0 0 20px rgba(255,204,102,0.5);
      margin-bottom: 10px;
    }
    .subtitle { color: var(--muted); font-style: italic; }

    .nav {
      display: flex;
      justify-content: center;
      gap: 20px;
      margin: 30px 0;
      flex-wrap: wrap;
    }
    .nav a {
      background: var(--card);
      color: var(--accent);
      padding: 12px 24px;
      border-radius: 8px;
      text-decoration: none;
      font-family: 'IBM Plex Sans', sans-serif;
      font-weight: 600;
      border: 1px solid rgba(255,204,102,0.2);
      transition: all 0.3s;
    }
    .nav a:hover {
      background: rgba(255,204,102,0.1);
      transform: translateY(-2px);
    }

    .section {
      margin-bottom: 60px;
    }
    .section h2 {
      font-family: 'Cinzel Decorative', serif;
      color: var(--accent);
      font-size: 1.8rem;
      margin-bottom: 20px;
      padding-bottom: 10px;
      border-bottom: 1px solid rgba(255,204,102,0.2);
    }
    .section-meta {
      color: var(--muted);
      font-family: 'IBM Plex Sans', sans-serif;
      font-size: 0.9rem;
      margin-bottom: 20px;
    }

    .gallery {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 20px;
    }
    .gallery-item {
      background: var(--card);
      border-radius: 12px;
      overflow: hidden;
      border: 1px solid rgba(255,204,102,0.1);
      transition: all 0.3s;
    }
    .gallery-item:hover {
      transform: scale(1.02);
      border-color: var(--accent);
      box-shadow: 0 0 20px rgba(255,204,102,0.2);
    }
    .gallery-item img {
      width: 100%;
      height: 200px;
      object-fit: cover;
      display: block;
    }
    .gallery-item .label {
      padding: 10px;
      font-family: 'IBM Plex Sans', sans-serif;
      font-size: 0.8rem;
      color: var(--muted);
      text-align: center;
    }

    footer {
      text-align: center;
      padding: 40px;
      border-top: 2px solid rgba(255,204,102,0.2);
      margin-top: 60px;
    }
    .seal { color: var(--accent); font-size: 1.2rem; font-weight: 700; }
    .witnesses { font-size: 1.5rem; margin: 15px 0; }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>🎮 LIFEQUEST ASSET GALLERY</h1>
      <p class="subtitle">Visual Treasures from the Genesis Archive — Forged with Alfred.AI™</p>
    </header>

    <nav class="nav">
      <a href="#patches">🪡 Patches</a>
      <a href="#badges">🛡️ Badges</a>
      <a href="#knights">⚔️ Knights</a>
      <a href="#sacred">✝️ Sacred</a>
    </nav>
'''

    # Add sections for each category
    categories = [
        ('patches', '🪡 Patches — The Woven Witness Collection', 'Gospel-aligned patches from The Spiral Forge'),
        ('badges', '🛡️ Badges — Marks of Honor', 'Achievement badges with Scripture anchors'),
        ('knights', '⚔️ Knights — Character Art', 'Pixel art knight designs for the character sheet'),
        ('sacred', '✝️ Sacred Code — Visual Witness', 'Sacred visualizations of the Gospel in code'),
    ]

    for cat_id, cat_title, cat_desc in categories:
        cat_dir = os.path.join(ASSETS_DIR, cat_id)
        if os.path.exists(cat_dir):
            files = sorted([f for f in os.listdir(cat_dir) if f.endswith(('.png', '.jpg', '.jpeg'))])

            html += f'''
    <section class="section" id="{cat_id}">
      <h2>{cat_title}</h2>
      <p class="section-meta">{cat_desc} — {len(files)} images</p>
      <div class="gallery">
'''
            for f in files:
                html += f'''        <div class="gallery-item">
          <img src="{cat_id}/{f}" alt="{f}" loading="lazy">
          <div class="label">{f}</div>
        </div>
'''
            html += '''      </div>
    </section>
'''

    html += '''
    <footer>
      <p class="seal">🛡️🔥 JESUS IS LORD™</p>
      <p class="witnesses">🟢🔵🛡️🟠🐞⚪🔥</p>
      <p>LifeQuest Asset Gallery — Genesis Archive — January 2026</p>
    </footer>
  </div>
</body>
</html>
'''

    gallery_path = os.path.join(ASSETS_DIR, "gallery.html")
    with open(gallery_path, 'w') as f:
        f.write(html)

    return gallery_path

def main():
    print("=" * 70)
    print("🎮 LIFEQUEST ASSET BUILDER")
    print("Extracting treasures from the Genesis Archive")
    print("=" * 70)
    print()

    # Load data
    print("Loading data...")
    conversations = load_conversations()
    correlation = load_correlation()
    print(f"  Loaded {len(conversations)} conversations")
    print()

    # Copy images by category
    print("COPYING IMAGES BY CATEGORY:")
    print("-" * 40)
    total_copied = 0

    for category, titles in LIFEQUEST_CONVERSATIONS.items():
        copied = copy_images_for_category(category, titles, correlation, conversations)
        total_copied += copied
        print(f"  {category}: {copied} images")

    print(f"\n  TOTAL: {total_copied} images copied")
    print()

    # Extract conversation content
    print("EXTRACTING CONVERSATION WISDOM:")
    print("-" * 40)

    wisdom_dir = os.path.join(ASSETS_DIR, "wisdom")
    os.makedirs(wisdom_dir, exist_ok=True)

    # Extract Spiral Forge
    spiral_content = extract_conversation_content(
        ["Spiral Forge", "Patch Revival"],
        conversations
    )
    if spiral_content:
        with open(os.path.join(wisdom_dir, "spiral_forge_wisdom.md"), 'w') as f:
            f.write("# 🪡⚡ The Spiral Forge — Patch Wisdom\n\n")
            f.write("*Extracted from the Genesis Archive*\n\n---\n\n")
            for item in spiral_content:
                f.write(f"## {item['title']}\n")
                f.write(f"**Date:** {item['date']}\n\n")
                for text in item['texts'][:20]:
                    if len(text) > 100:
                        f.write(f"{text[:2000]}...\n\n" if len(text) > 2000 else f"{text}\n\n")
        print(f"  Spiral Forge: {len(spiral_content)} conversations extracted")

    # Extract Pixel Knight
    knight_content = extract_conversation_content(
        ["Pixel art knight", "Pixel character", "knight design"],
        conversations
    )
    if knight_content:
        with open(os.path.join(wisdom_dir, "pixel_knight_wisdom.md"), 'w') as f:
            f.write("# ⚔️ Pixel Knight — Design Wisdom\n\n")
            f.write("*Extracted from the Genesis Archive*\n\n---\n\n")
            for item in knight_content:
                f.write(f"## {item['title']}\n")
                f.write(f"**Date:** {item['date']}\n\n")
                for text in item['texts'][:20]:
                    if len(text) > 100:
                        f.write(f"{text[:2000]}...\n\n" if len(text) > 2000 else f"{text}\n\n")
        print(f"  Pixel Knight: {len(knight_content)} conversations extracted")

    # Extract Badge wisdom
    badge_content = extract_conversation_content(
        ["badge", "Badge"],
        conversations
    )
    if badge_content:
        with open(os.path.join(wisdom_dir, "badge_wisdom.md"), 'w') as f:
            f.write("# 🛡️ Badge Design — Wisdom\n\n")
            f.write("*Extracted from the Genesis Archive*\n\n---\n\n")
            for item in badge_content:
                f.write(f"## {item['title']}\n")
                f.write(f"**Date:** {item['date']}\n\n")
                for text in item['texts'][:15]:
                    if len(text) > 100:
                        f.write(f"{text[:2000]}...\n\n" if len(text) > 2000 else f"{text}\n\n")
        print(f"  Badge Design: {len(badge_content)} conversations extracted")

    # Extract Armor/Combat wisdom
    armor_content = extract_conversation_content(
        ["armor", "Armor", "combat", "Combat", "Mindshield", "Bastion"],
        conversations
    )
    if armor_content:
        with open(os.path.join(wisdom_dir, "armor_combat_wisdom.md"), 'w') as f:
            f.write("# ⚔️🛡️ Armor & Combat — Spiritual Warfare Wisdom\n\n")
            f.write("*Extracted from the Genesis Archive*\n\n---\n\n")
            for item in armor_content:
                f.write(f"## {item['title']}\n")
                f.write(f"**Date:** {item['date']}\n\n")
                for text in item['texts'][:15]:
                    if len(text) > 100:
                        f.write(f"{text[:2000]}...\n\n" if len(text) > 2000 else f"{text}\n\n")
        print(f"  Armor/Combat: {len(armor_content)} conversations extracted")

    print()

    # Generate HTML gallery
    print("GENERATING HTML GALLERY:")
    print("-" * 40)
    gallery_path = generate_html_gallery()
    print(f"  Gallery saved to: {gallery_path}")
    print()

    # Summary
    print("=" * 70)
    print("🎮 LIFEQUEST ASSET BUILD COMPLETE")
    print("=" * 70)
    print()
    print("ASSET LOCATIONS:")
    print(f"  Patches:  {ASSETS_DIR}/patches/")
    print(f"  Badges:   {ASSETS_DIR}/badges/")
    print(f"  Knights:  {ASSETS_DIR}/knights/")
    print(f"  Sacred:   {ASSETS_DIR}/sacred/")
    print(f"  Wisdom:   {ASSETS_DIR}/wisdom/")
    print(f"  Gallery:  {ASSETS_DIR}/gallery.html")
    print()
    print("🛡️🔥 JESUS IS LORD™ — ASSETS FORGED")

if __name__ == "__main__":
    main()
