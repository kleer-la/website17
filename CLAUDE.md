# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Ruby Sinatra web application for Kleer's corporate website. It's a bilingual (Spanish/English) website that handles course catalogs, blog content, resources, and client information. The application integrates with external APIs for event management and supports various content types including training courses, blog articles, and downloadable resources.

## Technology Stack

- **Framework**: Sinatra (Ruby web framework)
- **Ruby Version**: ~3.3
- **Template Engine**: ERB
- **Testing**: RSpec for unit tests, Cucumber for integration/system tests
- **Deployment**: Heroku
- **External APIs**: Keventer API for event management
- **Caching**: Custom CacheService using concurrent-ruby
- **Internationalization**: R18n with Spanish and English support

## Development Environment Context

**Important**: This project is typically developed within a devcontainer. When Claude Code provides commands, these should be run inside the devcontainer environment by the developer, not on the host system. Claude Code runs on the Ubuntu host but cannot execute commands inside the devcontainer.

## Common Commands

### Development
```bash
# Start development server with auto-reload
gem install rerun
rerun 'ruby app.rb -o 0'

# Or with Puma
puma -p 4567

# Start with Docker
docker compose run --service-ports website17 bash
bundle install
puma -p 4567
```

### Testing
```bash
# Run all RSpec tests
rspec

# Run all Cucumber tests (excluding system tests)
cucumber

# Run system tests only
cucumber -p system

# Run specific test file
rspec spec/lib/services/cache_service_spec.rb
```

### Deployment
```bash
# Deploy to test environment (qa2.kleer.la)
git push heroku-test develop:main

# Deploy to production (www.kleer.la)
git push heroku master:main
```

### Utilities
```bash
# List all defined routes
rake routes

# Check CSS/SASS compilation
./sass.sh

# I18n management
i18n-tasks missing    # Find missing translations
i18n-tasks unused     # Find unused translations
i18n-tasks find meta_tag.press  # Find specific translation usage
```

### Linting
```bash
# Run RuboCop for code style checking
rubocop
```

## Architecture Overview

### Application Structure
- **app.rb**: Main application file with Sinatra configuration, routes, and middleware
- **controllers/**: Route handlers organized by feature (blog, training, services, etc.)
- **lib/**: Business logic and models
  - **models/**: Data models for various entities (catalog, news, resources, etc.)
  - **services/**: Service layer for API integration and caching
  - **helpers/**: View helpers and utility functions
- **views/**: ERB templates organized by feature
- **spec/**: RSpec tests mirroring the lib structure
- **features/**: Cucumber integration tests

### Key Components

#### Controllers
- Controllers are organized by feature area (blog, training, services, clients, etc.)
- Each controller handles specific routes and delegates to appropriate models/services
- Common functionality is shared through `controllers/helper.rb`

#### Models
- Simple Ruby classes representing business entities
- Most models interact with external APIs rather than a local database
- Key models: Catalog, News, Resources, Recommended, Assessment

#### Services
- **ApiAccessible**: Mixin for API integration with caching support
- **CacheService**: Thread-safe caching with TTL support using concurrent-ruby
- **KeventerApi**: Integration with external event management system
- **FileStoreService**: File storage management

#### Internationalization
- Uses R18n for bilingual support (Spanish/English)
- Locale files in `locales/` directory
- Language detection and routing handled in `app.rb`

### External Integrations
- **Keventer API**: Event and course management system
- **AWS S3**: File storage for certificates and resources
- **Recaptcha**: Form protection
- **Coveralls**: Test coverage reporting

## Development Notes

### Environment Variables
Essential environment variables for development:
- `RECAPTCHA_SITE_KEY` / `RECAPTCHA_SECRET_KEY`: For form protection
- `KEVENTER_URL`: External API endpoint (use test environment for development)
- `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`: For S3 integration

### Testing Strategy
- Unit tests (RSpec) for models and services
- Integration tests (Cucumber) for user workflows
- System tests for end-to-end functionality
- Test coverage tracked via SimpleCov and Coveralls

### Caching Strategy
- Custom CacheService provides thread-safe caching with TTL
- Cache keys typically include content type and language
- API responses are cached to reduce external API calls
- Cache can be cleared during development using `CacheService.clear`

### URL Structure
- Multilingual routing: `/es/` for Spanish, `/en/` for English
- Permanent redirects defined in `PERMANENT_REDIRECT` hash in `app.rb`
- Short URLs handled via `/s/:short_code` route

### Content Management
- Blog articles and resources are managed via external APIs
- Course catalog is dynamically loaded from Keventer API
- Static content is managed through ERB templates
- Images support WebP format with fallbacks