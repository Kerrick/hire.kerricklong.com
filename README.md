# [Kerrick Long’s Résumé](https://hire.kerricklong.com)

## Develop

### Watch changes
Run `npm start`.
[Parcel](https://parceljs.org) serves the site.

### Generate favicon
Run `npm run favicon`.
This creates images in the `src` folder.
It requires `librsvg` and `bc`.

### Build locally
Run `npm run build`.
This populates the `docs` folder.

## Deploy

### The mechanism
A pre-commit hook builds the site.
It stages the `docs` folder automatically.

### GitHub Pages
The site deploys from the `gh-pages` branch.
The source is the `/docs` folder.

## License

This project is licensed under the [MIT No Attribution License](LICENSE.txt).

## AI Content Declaration

Generative AI assisted with this project.
Specific declarations reside in each source file.
They detail the level and nature of AI involvement.
[declare-ai.org](https://declare-ai.org/)