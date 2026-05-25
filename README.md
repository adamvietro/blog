# Blog

A personal technical blog built with **Elixir** and **Phoenix** — documenting my ongoing journey through the Elixir ecosystem, functional programming, distributed systems, and LiveView architecture.

Live: [blog-wild-leaf-1554.fly.dev](https://blog-wild-leaf-1554.fly.dev)

---

## About

This is not a LiveView project. All state updates happen on page load or navigation, which shaped several of the technical decisions — particularly around the notification system.

Posts cover book notes, project work, coding exercises, and learnings from the Elixir ecosystem. New posts are added regularly as I read and build.

---

## Features

### Posts
- Admin-authored posts with title, content, cover image, published date, and visibility controls
- Tag system with many-to-many relationships between posts and tags
- Cover image support per post

### Search
- **Post Search** — partial-match title search across all posts
- **Tag Search** — browse and filter posts by tag

### Comments
- Any registered user can comment on posts
- Comment threads are visible on each post

### Notifications
The most technically interesting part of the project. Since this is a standard Phoenix app (not LiveView), real-time push isn't available — so notifications are handled via a database-backed unread count queried on every page load through the root layout.

When a comment is posted, notifications are created for:
- The post author
- Any other user who has previously commented on the same post

Each notification tracks the recipient (`user_id`), the triggering user (`actor_id`), and the relevant post (`post_id`), with a unique constraint preventing duplicate notifications per user/post pair.

A badge in the nav bar shows the unread count for logged-in users, queried fresh on each request:

```elixir
Blog.Notifications.unread_count(@current_user.id)
```

Visiting the notifications page marks all as read and clears the badge.

### Auth & Roles
- Public visitors can read posts
- Registered users can post comments and receive notifications
- Admin role required to create posts and tags

### Syntax Highlighting
Code blocks in posts use **Prism.js** with support for: Elixir, JavaScript, SQL, Rust, Bash, Python, and Erlang.

---

## Schema

```
User
  - username, email, hashed_password, admin (boolean)

Post
  - title, content, published_on, visibility
  - belongs_to: User
  - has_many: Comments, Tags (many-to-many), CoverImage

CoverImage
  - url
  - belongs_to: Post

Tag
  - name
  - many-to-many: Posts

Comment
  - content
  - belongs_to: Post, User

Notification
  - read (boolean)
  - belongs_to: User (recipient), Post, User as Actor (who triggered it)
  - unique constraint: [user_id, post_id]
```

---

## Tech Stack

| Layer               | Technology         |
| ------------------- | ------------------ |
| Language            | Elixir             |
| Web Framework       | Phoenix            |
| Database ORM        | Ecto               |
| Database            | PostgreSQL         |
| Syntax Highlighting | Prism.js           |
| Testing             | ExUnit (214 tests) |
| Deployment          | Fly.io + Docker    |

---

## Project Structure

```
lib/
  blog/
    accounts/        # User auth and roles
    posts/           # Post, Tag, CoverImage contexts
    comments/        # Comment context
    notifications/   # Notification creation, unread count, mark-as-read

  blog_web/
    controllers/     # Standard Phoenix controllers
    templates/       # HEEx templates
    router.ex        # Route definitions and plugs

test/
  blog/              # Context and schema tests
  blog_web/          # Controller and integration tests
```

---

## Getting Started

### Prerequisites

- Elixir
- Erlang/OTP
- PostgreSQL
- Node.js

### Setup

```bash
mix setup
```

### Run the server

```bash
mix phx.server
```

Visit: [http://localhost:4000](http://localhost:4000)

---

## Running Tests

```bash
mix test
```

---

## Learn More

- [Phoenix Framework](https://www.phoenixframework.org/)
- [My Game Site](https://game-site.fly.dev)
