
# 🖼️ Galeria Portugal – Backend (Strapi)

API headless para a plataforma de galeria de arte digital. Gerencia cidades, artistas, obras, eventos, quizzes, produtos e autenticação de utilizadores.

## Tecnologias

- Strapi v5
- SQLite (desenvolvimento) / PostgreSQL (produção)
- Node.js 18+

## 👥 Colaboração

Repositório de trabalho colaborativo (3 membros).  
O **frontend** está em [galeria-portugal-frontend](https://github.com/Vero279/galeria-portugal-frontend).

### Regras de trabalho

- **Nunca** trabalhar diretamente na `main`.
- Cada membro cria uma **branch** para cada funcionalidade/correção.
- Antes de começar: `git pull origin main`
- Abrir **Pull Request** (PR) para a `main` e pedir revisão.
- Resolver conflitos em conjunto.

### Workflow básico

```bash
# Clonar
git clone https://github.com/Vero279/galeria-portugal-backend.git
cd galeria-portugal-backend
npm install

# Criar branch
git checkout -b feature/minha-feature

# Commit e push
git add .
git commit -m "descrição clara"
git push origin feature/minha-feature

# Abrir Pull Request no GitHub
⚙️ Configuração local
Instalar dependências

bash
npm install
Variáveis de ambiente – copie .env.example para .env e preencha os valores gerados pelo Strapi (ou utilize os que surgem no primeiro npm run develop). Exemplo mínimo:

env
HOST=0.0.0.0
PORT=1337
APP_KEYS=...
API_TOKEN_SALT=...
ADMIN_JWT_SECRET=...
TRANSFER_TOKEN_SALT=...
JWT_SECRET=...
DATABASE_CLIENT=sqlite
DATABASE_FILENAME=.tmp/data.db
Iniciar servidor de desenvolvimento

bash
npm run develop
O painel admin estará em http://localhost:1337/admin.

🚀 Publicação (deploy)
Recomendamos Railway (gratuito, com PostgreSQL incluído).

Passos no Railway
Criar conta em railway.app (com GitHub).

Clicar New Project → Deploy from GitHub repo e selecionar este repositório.

Adicionar um PostgreSQL (gratuito) ao projeto – o Railway fornece uma DATABASE_URL.

Configurar variáveis de ambiente:

HOST=0.0.0.0

PORT=1337

APP_KEYS, API_TOKEN_SALT, ADMIN_JWT_SECRET, JWT_SECRET, TRANSFER_TOKEN_SALT – gere valores aleatórios seguros.

DATABASE_URL = a que foi gerada para o PostgreSQL.

(Não precisa de DATABASE_CLIENT nem DATABASE_FILENAME com PostgreSQL)

Build & Start: Railway detecta automaticamente, mas confirme:

Build Command: npm install && npm run build

Start Command: npm run start

Clicar Deploy.

Após o deploy, o Railway fornece um domínio público (ex: https://galeria-backend.up.railway.app).
O painel admin estará em https://dominio/admin.

Alternativa gratuita com limitações: Render (750 horas/mês), processo muito semelhante.

🔗 Ligação com o frontend
O frontend deve conhecer a URL pública do backend através da variável VITE_STRAPI_URL (ex: https://galeria-backend.up.railway.app).

CORS – No ficheiro config/middlewares.js, configure o origin para aceitar o domínio do frontend (Netlify) e o endereço local de desenvolvimento:

js
module.exports = [
  "strapi::logger",
  "strapi::errors",
  {
    name: "strapi::security",
    config: {
      contentSecurityPolicy: {
        useDefaults: true,
        directives: {
          "connect-src": ["'self'", "https:"],
          "img-src": ["'self'", "data:", "blob:", "https://images.unsplash.com"],
          "media-src": ["'self'", "data:", "blob:"],
          upgradeInsecureRequests: null,
        },
      },
    },
  },
  {
    name: "strapi::cors",
    config: {
      enabled: true,
      origin: ["https://seu-frontend.netlify.app", "http://localhost:5173"],
      headers: ["*"],
      methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"],
    },
  },
  "strapi::poweredBy",
  "strapi::query",
  "strapi::body",
  "strapi::session",
  "strapi::favicon",
  "strapi::public",
];
Permissões públicas: No painel do Strapi (publicado), vá a Settings → Users & Permissions → Roles → Public e ative find e findOne para os content‑types que devem ser acessíveis sem autenticação (City, Artist, Artwork, ArtistEvent, ArtistQuiz, Product).

📦 Content‑Types necessários (criar no Strapi)
Utilize o Content‑Type Builder para criar os seguintes tipos (campos principais):

Tipo	Campos (string, text, etc.)	Relações
City	name, slug(uid), image_url, description, is_published (boolean)	–
Artist	name, slug(uid), bio, profile_image, cover_image, medium, is_published, rating(number), total_reviews(integer)	belongsTo City
Artwork	title, image_url, year(integer), medium, dimensions, price(decimal), is_published	belongsTo Artist
ArtworkDescription	description(text)	belongsTo Artwork
ArtistEvent	title, description, event_date(datetime), location, image_url, is_published	belongsTo City, belongsTo Artist
ArtistQuiz	title, description, is_published	belongsTo Artist
QuizQuestion	question, correct_answer, option_a, option_b, option_c, option_d	belongsTo ArtistQuiz
Product	title, description, image_url, price(decimal), category, stock_quantity(integer), is_available(boolean)	belongsTo Artist, belongsTo Artwork(opcional)
Nota: O Strapi já tem o User (utilizador). Crie roles personalizadas Admin, Artist, Customer no plugin Users & Permissions.

🔐 Segurança (produção)
Desative a criação de novos utilizadores (Settings → Users & Permissions → Advanced → Allow new registrations = false), a menos que queira registo público.

Restrinja o acesso ao painel admin por IP (se o serviço de alojamento permitir).

Use API Tokens com permissões limitadas em vez de token admin sempre que possível.

💾 Backup dos dados
No Railway, pode exportar a base de dados PostgreSQL através da interface.

Periodicamente, use o plugin Strapi Export/Import ou faça dump manual.

📝 Notas importantes
Nunca faça commit do ficheiro .env (deve estar no .gitignore).

Os APP_KEYS, API_TOKEN_SALT, etc. são gerados pelo Strapi no primeiro arranque – guarde‑os em segurança.

Em produção, não use SQLite (não adequado para múltiplos processos). Use PostgreSQL.

Licença
MIT


---------------------------------------------------------
---------------------------------------------------------
---------------------------------------------------------


# 🚀 Getting started with Strapi

Strapi comes with a full featured [Command Line Interface](https://docs.strapi.io/dev-docs/cli) (CLI) which lets you scaffold and manage your project in seconds.

### `develop`

Start your Strapi application with autoReload enabled. [Learn more](https://docs.strapi.io/dev-docs/cli#strapi-develop)

```
npm run develop
# or
yarn develop
```

### `start`

Start your Strapi application with autoReload disabled. [Learn more](https://docs.strapi.io/dev-docs/cli#strapi-start)

```
npm run start
# or
yarn start
```

### `build`

Build your admin panel. [Learn more](https://docs.strapi.io/dev-docs/cli#strapi-build)

```
npm run build
# or
yarn build
```

## ⚙️ Deployment

Strapi gives you many possible deployment options for your project including [Strapi Cloud](https://cloud.strapi.io). Browse the [deployment section of the documentation](https://docs.strapi.io/dev-docs/deployment) to find the best solution for your use case.

```
yarn strapi deploy
```

## 📚 Learn more

- [Resource center](https://strapi.io/resource-center) - Strapi resource center.
- [Strapi documentation](https://docs.strapi.io) - Official Strapi documentation.
- [Strapi tutorials](https://strapi.io/tutorials) - List of tutorials made by the core team and the community.
- [Strapi blog](https://strapi.io/blog) - Official Strapi blog containing articles made by the Strapi team and the community.
- [Changelog](https://strapi.io/changelog) - Find out about the Strapi product updates, new features and general improvements.

Feel free to check out the [Strapi GitHub repository](https://github.com/strapi/strapi). Your feedback and contributions are welcome!

## ✨ Community

- [Discord](https://discord.strapi.io) - Come chat with the Strapi community including the core team.
- [Forum](https://forum.strapi.io/) - Place to discuss, ask questions and find answers, show your Strapi project and get feedback or just talk with other Community members.
- [Awesome Strapi](https://github.com/strapi/awesome-strapi) - A curated list of awesome things related to Strapi.

---

<sub>🤫 Psst! [Strapi is hiring](https://strapi.io/careers).</sub>
