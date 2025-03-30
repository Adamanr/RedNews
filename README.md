# News Portal - <span style="color:#FF0000">Red</span>News 📰

**RedNews** is a modern online portal designed for publishing and managing news and articles. This tool allows you to create and publish articles, share the latest news, and stay updated with new publications. By using the News Portal's functionality, you gain the following features:

- **Publish articles and news**: You can add new content by specifying the title, content, category, and tags, making the content creation process convenient and fast 📝
- **Create channels**: To organize content efficiently, you can create thematic channels that help structure information and simplify management 📂
- **Filter and sort**: With built-in filters by categories, tags, and publication dates, you can easily find the desired material in just a few seconds 🔍
- **Interact with content**: The portal provides like functionality, allowing users to express their opinions and engage with published content ❤️
- **Multilingual support**: Fully localized in English, Russian, Chinese, and Japanese 🌐


![ 📸](priv/static/images/rednews.jpg)

## Technologies 💻

- **Language**: Elixir 🧪
- **Database**: PostgreSQL 🗄️
- **Libraries**:
  - Ecto {3.10} 📚
  - Phoenix {1.7} 📚
  - Tailwind {0.2} 📚
  - ExDoc {0.36} 📚
- **ORM**: Ecto 🛠️
- **Templating Engine**: HEEx 📝

## Installation and Launch 🚀

### 1. Install Dependencies

Ensure you have the following installed:

- Elixir (version 1.18.1) 🧪
- PostgreSQL (version 15) 🗄️
- Node.js (version 16 or higher) 📦

### 2. Clone the Repository

```bash
git clone https://github.com/adamanq/rednews.git
cd rednews
```

### 3. Install Project Dependencies

```bash
mix deps.get
```

### 4. Set Up the Database

Create the database and configure the connection in the `config/dev.exs` file:

```elixir
config :rednews, Rednews.Repo,
  username: "your_db_user",
  password: "your_db_password",
  database: "rednews_dev",
  hostname: "localhost",
  port: 5432,
  pool_size: 10
```

Create and run migrations:

```bash
mix ecto.create
mix ecto.migrate
```

### 5. Run the Application

```bash
mix phx.server
```

The application will be available at: [http://localhost:4000](http://localhost:4000). 🌐

## If You Want to Run in a Container 📦

> ❗️❗️ Currently, the stability of the application in a container leaves much to be desired, so it is recommended to use the standard build method ❗️❗️

### 6. Build the Portal Image

```bash
docker build .
```

### 7. Run the Container Group for the Application and Database

```bash
docker-compose up --build
```

### 8. Install Project Dependencies

```bash
docker-compose exec app mix deps.get
```

### 9. Set Up the Database

Create the database and configure the connection in the `config/dev.exs` file:

```elixir
config :rednews, Rednews.Repo,
  username: "your_db_user",
  password: "your_db_password",
  database: "rednews_dev",
  hostname: "db",
  port: 5432,
  pool_size: 10
```

Create and run migrations:

```bash
docker-compose exec app mix ecto.create
docker-compose exec app mix ecto.migrate
```

The application will be available at: [http://localhost:4000](http://localhost:4000). 🌐

## Usage 📖

1. **Registration and Login**: Create an account or log in
2. **Publishing Content**: Add an article or news by selecting a category and tags
3. **Filtering and Search**: Use filters to find the desired materials
4. **Likes and Comments**: Engage with content by expressing your opinion

## Project Structure 🗂️

- **lib/rednews** — Main application code
  - **accounts.ex** — Context for working with users and channels 👤
  - **posts.ex** — Context for working with articles, news, likes, and comments 📝
- **priv/repo/migrations** — Database migrations 🗄️
- **assets/** — Frontend resources (CSS, JavaScript) 🎨
- **config/** — Configuration files ⚙️

## License 📜

This project is distributed under the MIT License. For more details, see the [LICENSE](LICENSE) file.

## Author 👤

- [Adamanr](https://github.com/adamanr) 🧑‍💻

## How to Contribute 🤝

If you want to improve the project, follow these steps:

1. Fork the repository. 🍴
2. Create a branch for your feature (`git checkout -b feature/AmazingFeature`) 🌿
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`) 💾
4. Push to your fork (`git push origin feature/AmazingFeature`) 🚀
5. Create a Pull Request 📥

If you have any questions or suggestions, create an [Issue](https://github.com/adamanr/rednews/issues) or contact me! 📩

[![Open Source Love](https://firstcontributions.github.io/open-source-badges/badges/open-source-v1/open-source.svg)](https://github.com/firstcontributions/open-source-badges)
[<img align="right" width="150" src="https://firstcontributions.github.io/assets/Readme/join-slack-team.png">](https://join.slack.com/t/firstcontributors/shared_invite/zt-vchl8cde-S0KstI_jyCcGEEj7rSTQiA)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Open Source Helpers](https://www.codetriage.com/roshanjossey/first-contributions/badges/users.svg)](https://www.codetriage.com/roshanjossey/first-contributions)
#

#### _Read this in [other languages](translations/Translations.md)._

<kbd>[<img title="Shqip" alt="Shqip" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/al.svg" width="22">](translations/README.al.md)</kbd>
<kbd>[<img title="Azərbaycan dili" alt="Azərbaycan dili" src="https://cdn.statically.io/flags/az.svg" width="22">](translations/README.aze.md)</kbd>
<kbd>[<img title="বাংলা" alt="বাংলা" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/bd.svg" width="22">](translations/README.bn.md)</kbd>
<kbd>[<img title="Bulgarian" alt="Bulgarian" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/bg.svg" width="22">](translations/README.bg.md)</kbd>
<kbd>[<img title="Português" alt="Português" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/br.svg" width="22">](translations/README.pt_br.md)</kbd>
<kbd>[<img title="Català" alt="Català" src="https://firstcontributions.github.io/assets/Readme/catalan1.png" width="22">](translations/README.ca.md)</kbd>
<kbd>[<img title="中文 (Simplified)" alt="中文 (Simplified)" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/cn.svg" width="22">](translations/README.chs.md)</kbd>
<kbd>[<img title="Czech" alt="Czech" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/cz.svg" width="22">](translations/README.cs.md)</kbd>
<kbd>[<img title="Deutsch" alt="Deutsch" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/de.svg" width="22">](translations/README.de.md)</kbd>
<kbd>[<img title="Dansk" alt="Dansk" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/dk.svg" width="22">](translations/README.da.md)</kbd>
<kbd>[<img title="العربية" alt="العربية" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/eg.svg" width="22">](translations/README.eg.md)</kbd>
<kbd>[<img title="Española" alt="Española" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/es.svg" width="22">](translations/README.es.md)</kbd>
<kbd>[<img title="Française" alt="Française" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/fr.svg" width="22">](translations/README.fr.md)</kbd>
<kbd>[<img title="Galego" alt="Galego" src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/64/Flag_of_Galicia.svg/1200px-Flag_of_Galicia.svg.png" width="22">](translations/README.gl.md)</kbd>
<kbd>[<img title="Ελληνικά" alt="Ελληνικά" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/gr.svg" width="22">](translations/README.gr.md)</kbd>
<kbd>[<img title="ქართული" alt="ქართული" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ge.svg" width="22">](translations/README.ge.md)</kbd>
<kbd>[<img title="Magyar" alt="Magyar" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/hu.svg" width="22">](translations/README.hu.md)</kbd>
<kbd>[<img title="Bahasa Indonesia" alt="Bahasa Indonesia" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/id.svg" width="22">](translations/README.id.md)</kbd>
<kbd>[<img title="עִברִית" alt="עִברִית" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/il.svg" width="22">](translations/README.hb.md)</kbd>
<kbd>[<img title="हिंदी/ગુજરાતી/मराठी/മലയാളം/ಕನ್ನಡ/తెలుగు/छत्तीसगढ़ी/বাংলা/தமிழ்" alt="हिंदी/ગુજરાતી/मराठी/മലയാളം/ಕನ್ನಡ/తెలుగు/छत्तीसगढ़ी/বাংলা/தமிழ்" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/in.svg" width="22">](translations/Translations.md)</kbd>
<kbd>[<img title="தமிழ்" alt="தமிழ்" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/lk.svg" width="22">](translations/README.ta.md)</kbd>
<kbd>[<img title="فارسی" alt="فارسی" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ir.svg" width="22">](translations/README.fa.md)</kbd>
<kbd>[<img title="Persian_Finglish" alt="Persian_Finglish" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ir.svg" width="22">](translations/README.fa.en.md)</kbd>
<kbd>[<img title="Italiano" alt="Italiano" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/it.svg" width="22">](translations/README.it.md)</kbd>
<kbd>[<img title="日本語" alt="日本語" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/jp.svg" width="22">](translations/README.ja.md)</kbd>
<kbd>[<img title="Kiswahili (Kenya)" alt="Kiswahili (Kenya)" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ke.svg" width="22">](translations/README.kws.md)</kbd>
<kbd>[<img title="한국어" alt="한국어" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/kr.svg" width="22"> <img title="한국어" alt="한국어" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/kp.svg" width="22">](translations/README.ko.md)</kbd>
<kbd>[<img title="Lietuvių kalba" alt="Lietuvių kalba" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/lt.svg" width="22">](translations/README.lt.md)</kbd>
<kbd>[<img title="Limba Română" alt="Limba Română" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/md.svg" width="22"> <img title="Limba Română" alt="Limba Română" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ro.svg" width="22">](translations/README.ro.md)</kbd>
<kbd>[<img title="မြန်မာ" alt="မြန်မာ" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/mm.svg" width="22">](translations/README.mm_unicode.md)</kbd>
<kbd>[<img title="Македонски" alt="Македонски" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/mk.svg" width="22">](translations/README.mk.md)</kbd>
<kbd>[<img title="Español de México" alt="Español de México" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/mx.svg" width="22">](translations/README.mx.md)</kbd>
<kbd>[<img title="Bahasa Melayu / بهاس ملايو‎ / Malay" alt="Bahasa Melayu / بهاس ملايو‎ / Malay" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/my.svg" width="22">](translations/README.my.md)</kbd>
<kbd>[<img title="Dutch" alt="Dutch" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/nl.svg" width="22">](translations/README.nl.md)</kbd>
<kbd>[<img title="Norsk" alt="Norsk" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/no.svg" width="22">](translations/README.no.md)</kbd>
<kbd>[<img title="नेपाली" alt="नेपाली" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/np.svg" width="15">](translations/README.np.md)</kbd>
<kbd>[<img title="Wikang Filipino" alt="Wikang Filipino" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ph.svg" width="22">](translations/README.tl.md)</kbd>
<kbd>[<img title="English (Pirate)" alt="English (Pirate)" src="https://firstcontributions.github.io/assets/Readme/pirate.png" width="22">](translations/README.en-pirate.md)</kbd>
<kbd>[<img title="اُاردو" alt="اردو" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/pk.svg" width="22">](translations/README.ur.md)</kbd>
<kbd>[<img title="Polski" alt="Polski" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/pl.svg" width="22">](translations/README.pl.md)</kbd>
<kbd>[<img title="Português (Portugal)" alt="Português (Portugal)" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/pt.svg" width="22">](translations/README.pt-pt.md)</kbd>
<kbd>[<img title="Русский язык" alt="Русский язык" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ru.svg" width="22">](translations/README.ru.md)</kbd>
<kbd>[<img title="عربى" alt="عربى" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/sa.svg" width="22">](translations/README.ar.md)</kbd>
<kbd>[<img title="Svenska" alt="Svenska" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/se.svg" width="22">](translations/README.se.md)</kbd>
<kbd>[<img title="Slovenčina" alt="Slovenčina" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/sk.svg" width="22">](translations/README.slk.md)</kbd>
<kbd>[<img title="Slovenščina" alt="Slovenščina" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/si.svg" width="22">](translations/README.sl.md)</kbd>
<kbd>[<img title="ภาษาไทย" alt="ภาษาไทย" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/th.svg" width="22">](translations/README.th.md)</kbd>
<kbd>[<img title="Türkçe" alt="Türkçe" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/tr.svg" width="22">](translations/README.tr.md)</kbd>
<kbd>[<img title="中文(Traditional)" alt="中文(Traditional)" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/tw.svg" width="22">](translations/README.cht.md)</kbd>
<kbd>[<img title="Українська" alt="Українська" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ua.svg" width="22">](translations/README.ua.md)</kbd>
<kbd>[<img title="Tiếng Việt" alt="Tiếng Việt" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/vn.svg" width="22">](translations/README.vn.md)</kbd>
<kbd>[<img title="Zulu (South Africa)" alt="Zulu (South Africa)" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/za.svg" width="22">](translations/README.zul.md)</kbd>
<kbd>[<img title="Afrikaans (South Africa)" alt="Afrikaans (South Africa)" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/za.svg" width="22">](translations/README.afk.md)</kbd>
<kbd>[<img title="Igbo (Nigeria)" alt="Igbo (Nigeria)" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ng.svg" width="22">](translations/README.igb.md)</kbd>
<kbd>[<img title="Latvia" alt="Latvia" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/lv.svg" width="22">](translations/README.lv.md)</kbd>
<kbd>[<img title="Suomeksi" alt="Suomeksi" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/fi.svg" width="22">](translations/README.fi.md)</kbd>
<kbd>[<img title="Беларуская мова" alt="Беларуская мова" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/by.svg" width="22">](translations/README.by.md)</kbd>
<kbd>[<img title="Српски" alt="Српски" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/rs.svg" width="22">](translations/README.sr.md)</kbd>
<kbd>[<img title="Қазақша" alt="Қазақша" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/kz.svg" width="22">](translations/README.kz.md)</kbd>
<kbd>[<img title="Bosanski" alt="Bosanski" src="https://cdn.staticaly.com/gh/hjnilsson/country-flags/master/svg/ba.svg" width="22">](translations/README.bih.md)</kbd>
#

# First Contributions

This project aims to simplify and guide the way beginners make their first contribution. If you are looking to make your first contribution, follow the steps below.

_If you're not comfortable with command line, [here are tutorials using GUI tools.](#tutorials-using-other-tools)_

<img align="right" width="300" src="https://firstcontributions.github.io/assets/Readme/fork.png" alt="fork this repository" />

#### If you don't have git on your machine, [install it](https://help.github.com/articles/set-up-git/).

## Fork this repository

Fork this repository by clicking on the fork button on the top of this page.
This will create a copy of this repository in your account.

## Clone the repository

<img align="right" width="300" src="https://firstcontributions.github.io/assets/Readme/clone.png" alt="clone this repository" />

Now clone the forked repository to your machine. Go to your GitHub account, open the forked repository, click on the code button and then click the _copy to clipboard_ icon.

Open a terminal and run the following git command:

```
git clone "url you just copied"
```

where "url you just copied" (without the quotation marks) is the url to this repository (your fork of this project). See the previous steps to obtain the url.

<img align="right" width="300" src="https://firstcontributions.github.io/assets/Readme/copy-to-clipboard.png" alt="copy URL to clipboard" />

For example:

```
git clone https://github.com/this-is-you/first-contributions.git
```

where `this-is-you` is your GitHub username. Here you're copying the contents of the first-contributions repository on GitHub to your computer.

## Create a branch

Change to the repository directory on your computer (if you are not already there):

```
cd first-contributions
```

Now create a branch using the `git checkout` command:

```
git checkout -b your-new-branch-name
```

For example:

```
git checkout -b add-alonzo-church
```

(The name of the branch does not need to have the word _add_ in it, but it's a reasonable thing to include because the purpose of this branch is to add your name to a list.)

## Make necessary changes and commit those changes

Now open `Contributors.md` file in a text editor, add your name to it. Don't add it at the beginning or end of the file. Put it anywhere in between. Now, save the file.

<img align="right" width="450" src="https://firstcontributions.github.io/assets/Readme/git-status.png" alt="git status" />

If you go to the project directory and execute the command `git status`, you'll see there are changes.

Add those changes to the branch you just created using the `git add` command:

```
git add Contributors.md
```

Now commit those changes using the `git commit` command:

```
git commit -m "Add <your-name> to Contributors list"
```

replacing `<your-name>` with your name.

## Push changes to GitHub

Push your changes using the command `git push`:

```
git push origin <add-your-branch-name>
```

replacing `<add-your-branch-name>` with the name of the branch you created earlier.

## Submit your changes for review

If you go to your repository on GitHub, you'll see a `Compare & pull request` button. Click on that button.

<img style="float: right;" src="https://firstcontributions.github.io/assets/Readme/compare-and-pull.png" alt="create a pull request" />

Now submit the pull request.

<img style="float: right;" src="https://firstcontributions.github.io/assets/Readme/submit-pull-request.png" alt="submit pull request" />

Soon I'll be merging all your changes into the master branch of this project. You will get a notification email once the changes have been merged.

## Where to go from here?

Congrats! You just completed the standard _fork -> clone -> edit -> pull request_ workflow that you'll encounter often as a contributor!

Celebrate your contribution and share it with your friends and followers by going to [web app](https://firstcontributions.github.io/#social-share).

You could join our slack team in case you need any help or have any questions. [Join slack team](https://join.slack.com/t/firstcontributors/shared_invite/zt-vchl8cde-S0KstI_jyCcGEEj7rSTQiA).

Now let's get you started with contributing to other projects. We've compiled a list of projects with easy issues you can get started on. Check out [the list of projects in the web app](https://firstcontributions.github.io/#project-list).

### [Additional material](additional-material/git_workflow_scenarios/additional-material.md)

## Tutorials Using Other Tools

| <a href="gui-tool-tutorials/github-desktop-tutorial.md"><img alt="GitHub Desktop" src="https://desktop.github.com/images/desktop-icon.svg" width="100"></a> | <a href="gui-tool-tutorials/github-windows-vs2017-tutorial.md"><img alt="Visual Studio 2017" src="https://upload.wikimedia.org/wikipedia/commons/c/cd/Visual_Studio_2017_Logo.svg" width="100"></a> | <a href="gui-tool-tutorials/gitkraken-tutorial.md"><img alt="GitKraken" src="https://firstcontributions.github.io/assets/gui-tool-tutorials/gitkraken-tutorial/gk-icon.png" width="100"></a> | <a href="gui-tool-tutorials/github-windows-vs-code-tutorial.md"><img alt="VS Code" src="https://upload.wikimedia.org/wikipedia/commons/2/2d/Visual_Studio_Code_1.18_icon.svg" width=100></a> | <a href="gui-tool-tutorials/sourcetree-macos-tutorial.md"><img alt="Sourcetree App" src="https://wac-cdn.atlassian.com/dam/jcr:81b15cde-be2e-4f4a-8af7-9436f4a1b431/Sourcetree-icon-blue.svg" width=100></a> | <a href="gui-tool-tutorials/github-windows-intellij-tutorial.md"><img alt="IntelliJ IDEA" src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/9c/IntelliJ_IDEA_Icon.svg/512px-IntelliJ_IDEA_Icon.svg.png" width=100></a> |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [GitHub Desktop](gui-tool-tutorials/github-desktop-tutorial.md)                                                                                             | [Visual Studio 2017](gui-tool-tutorials/github-windows-vs2017-tutorial.md)                                                                                                                          | [GitKraken](gui-tool-tutorials/gitkraken-tutorial.md)                                                               | [Visual Studio Code](gui-tool-tutorials/github-windows-vs-code-tutorial.md)                                                                                                                  | [Atlassian Sourcetree](gui-tool-tutorials/sourcetree-macos-tutorial.md)                                                                                                                                      | [IntelliJ IDEA](gui-tool-tutorials/github-windows-intellij-tutorial.md)                                                                                                                   |
添加内容
