# 👑 eFootball Kings Online

**A modern online eFootball tournament and league management platform.**

eFootball Kings Online is a web-based platform designed to manage competitive eFootball leagues and tournaments. It provides players with a central place to register, view fixtures, submit match results, track standings, and compete for rankings, while administrators get tools to manage competitions, players, fixtures, and match verification.

---

## 🚀 Features

### 👤 Player Management

- Player registration and authentication
- Player profiles
- Player statistics
- Win / draw / loss records
- Goals scored and conceded
- Goal difference
- Points
- Player rankings
- ELO rating foundation
- Player suspension and activation
- Match history

### 🏆 Competition Management

- Create and manage seasons
- Create competitions
- Register players
- League competitions
- Tournament foundation
- Competition status management
- Automatic fixture generation
- Home and away round-robin fixtures
- Competition registration

### ⚽ Match Management

Players can submit their match results together with screenshot evidence.

Administrators can:

- Review submitted results
- Approve results
- Reject results
- Manage fixtures
- Resolve disputed matches
- Prevent invalid results from affecting standings

Once a result is approved, the official match record is created and competition statistics are updated.

### 📊 Automatic Standings

The platform tracks:

| Statistic | Description |
|---|---|
| Played | Number of completed matches |
| Wins | Matches won |
| Draws | Matches drawn |
| Losses | Matches lost |
| GF | Goals for |
| GA | Goals against |
| GD | Goal difference |
| Points | Competition points |

Default scoring:

- 🟢 Win — **3 points**
- 🟡 Draw — **1 point**
- 🔴 Loss — **0 points**

Standings can use:

1. Points
2. Goal difference
3. Goals scored
4. Player name

---

## 🔐 Authentication & Security

The application uses **Supabase Authentication** and Row Level Security (RLS).

The platform supports separate roles for:

- Players
- Administrators

Database policies are designed to prevent players from modifying official competition data directly.

Administrators control:

- Players
- Competitions
- Seasons
- Fixtures
- Match approvals
- Suspensions
- Competition management

---

## 🗄️ Technology Stack

### Frontend

- HTML5
- CSS3
- JavaScript
- Progressive Web App (PWA)

### Backend

- Supabase
- PostgreSQL
- Supabase Authentication
- Supabase Storage

### Deployment

The application can be deployed as a static web application using platforms such as:

- Vercel
- Netlify
- GitHub Pages (with appropriate backend configuration)

---

## 📁 Project Structure

```text
eFootball-Kings-Online/
│
├── index.html
├── app.js
├── styles.css
├── config.js
│
├── manifest.webmanifest
├── sw.js
├── icon.svg
│
├── supabase-schema.sql
├── supabase-update-played-games-and-draw.sql
│
└── README.md
```

---

## ⚙️ Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/YOUR_USERNAME/efootball-kings-online.git
```

Enter the project directory:

```bash
cd efootball-kings-online
```

---

### 2. Create a Supabase project

Create a new project on Supabase.

You will need:

```text
Project URL
Anon/Public Key
```

---

### 3. Set up the database

Open the **Supabase SQL Editor**.

Run:

```text
supabase-schema.sql
```

Then run any additional SQL migration files included in the project.

The database will create the required tables, relationships, policies, functions and competition structures.

---

### 4. Configure Supabase

Open:

```text
config.js
```

Add your Supabase credentials:

```javascript
const SUPABASE_URL = "YOUR_SUPABASE_PROJECT_URL";
const SUPABASE_ANON_KEY = "YOUR_SUPABASE_ANON_KEY";
```

> ⚠️ Never commit private Supabase service-role keys or other server secrets to GitHub.

The public/anon key is designed for browser applications when your Supabase Row Level Security policies are correctly configured.

---

## 👑 Creating the First Administrator

Register an account through the application.

Then use the Supabase SQL Editor to promote the account to administrator according to the SQL instructions included in the project.

After becoming an administrator, you can:

1. Create a season
2. Create a competition
3. Register players
4. Generate fixtures
5. Manage matches
6. Approve submitted results
7. Monitor standings

---

## 🔄 Match Workflow

The normal match workflow is:

```text
Player
   │
   ▼
View Fixture
   │
   ▼
Play Match
   │
   ▼
Submit Result
   │
   ├── Score
   ├── Opponent
   └── Screenshot Evidence
   │
   ▼
Admin Review
   │
   ├── Reject ──────► Player Corrects Submission
   │
   └── Approve
          │
          ▼
     Official Result
          │
          ▼
     Update Statistics
          │
          ▼
      League Table
```

---

## 🏟️ Competition Workflow

Administrators can follow this workflow:

```text
Create Season
      ↓
Create Competition
      ↓
Register Players
      ↓
Generate Fixtures
      ↓
Players Play Matches
      ↓
Submit Results
      ↓
Admin Verification
      ↓
Official Results
      ↓
Automatic Standings
```

---

## 📱 Progressive Web App

eFootball Kings Online includes PWA support.

The application includes:

```text
manifest.webmanifest
sw.js
icon.svg
```

This allows the platform to be installed on supported devices and behave more like a native application.

---

## 🛡️ Security

Security is an important part of the platform.

The application uses:

- Supabase Authentication
- PostgreSQL
- Row Level Security
- Role-based access
- Admin-controlled result approval
- Protected competition data

### Important

Do **not** put private credentials into:

```text
config.js
```

Do not commit:

```text
service_role
private API keys
database passwords
payment secrets
```

to a public GitHub repository.

---

## 🧪 Development

Because this is currently a browser-based application, you can run it locally using a simple static server.

For example:

```bash
python -m http.server 8000
```

Then open:

```text
http://localhost:8000
```

Alternatively, use VS Code with the **Live Server** extension.

---

## 🚀 Deployment

### Vercel

The project can be deployed to Vercel as a static site.

Recommended configuration:

```text
Framework Preset: Other
Build Command: None
Output Directory: .
Install Command: None
```

Because the current frontend does not require a Node.js build process.

After deployment, make sure the production site is configured to use the correct Supabase project.

---

## 🗺️ Roadmap

eFootball Kings Online is being developed toward a complete competitive gaming platform.

### Current

- [x] Player authentication
- [x] Player management
- [x] Seasons
- [x] Competitions
- [x] Fixtures
- [x] Match submissions
- [x] Screenshot evidence
- [x] Admin verification
- [x] League standings
- [x] Win/draw/loss system
- [x] Points system
- [x] Player suspension
- [x] PWA foundation

### Planned

- [ ] Full tournament bracket system
- [ ] Group stages
- [ ] Knockout stages
- [ ] Player ELO rankings
- [ ] Advanced player statistics
- [ ] Match disputes
- [ ] Automated notifications
- [ ] Competition entry fees
- [ ] M-Pesa integration
- [ ] Prize management
- [ ] Payment history
- [ ] Admin analytics dashboard
- [ ] Public player rankings
- [ ] Player achievements
- [ ] Seasons archive
- [ ] Live match centre
- [ ] Real-time notifications
- [ ] Mobile application
- [ ] Desktop application
- [ ] Multi-country competitions

---

## 💳 Future Payments

The platform is designed to support paid competitions in the future.

Planned payment functionality includes:

- M-Pesa
- Competition entry fees
- Payment verification
- Player payment history
- Tournament revenue tracking
- Prize management

Payment processing should be implemented using secure server-side integrations rather than exposing payment credentials in the frontend.

---

## 🤝 Contributing

Contributions, ideas, bug reports and feature requests are welcome.

To contribute:

1. Fork the repository
2. Create a feature branch

```bash
git checkout -b feature/my-new-feature
```

3. Make your changes
4. Commit your changes

```bash
git commit -m "Add my new feature"
```

5. Push the branch

```bash
git push origin feature/my-new-feature
```

6. Open a Pull Request

---

## 🐛 Bug Reports

If you discover a bug, please provide:

- Description of the problem
- Steps to reproduce it
- Expected behaviour
- Actual behaviour
- Browser/device
- Screenshots where applicable

---

## 📄 License

This project currently does not specify an open-source license.

Unless a license is added to this repository, all rights are reserved by the project owner.

---

## 👑 About eFootball Kings

**eFootball Kings Online** is being developed as a competitive gaming platform focused on organized eFootball competitions.

The long-term goal is to provide players with a professional environment where they can:

> **Compete. Prove yourself. Climb the rankings. Become King. 👑**

---

## ⭐ Support the Project

If you like the project:

⭐ Star the repository

🍴 Fork the project

🐛 Report bugs

💡 Suggest features

🤝 Contribute improvements

---

**eFootball Kings Online — Compete. Prove Yourself. Become King. 👑**
