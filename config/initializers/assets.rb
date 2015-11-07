# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

Rails.application.config.assets.precompile += [
  /\w+\.(?!js|css)$/,
  'acao_dashboard.css',
  'acao_dashboard-stage1.js',
  'acao_dashboard-stage2.js',
  'ext/ext.js',
  'markerwithlabel.js',
  'ext/ext-theme-neptune.js',
  'ext/resources/ext-theme-classic/ext-theme-classic-all.css',
  'ext/resources/ext-theme-gray/ext-theme-gray-all.css',
  'ext/resources/ext-theme-access/ext-theme-access-all.css',
  'ext/resources/ext-theme-neptune/ext-theme-neptune-all.css',
  'ext/resources/ext-theme-redtune/ext-theme-redtune-all.css',
  'radar.js',
]

