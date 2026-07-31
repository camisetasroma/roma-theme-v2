{#/*============================================================================
style.scss.tpl

    -This file contains all the theme styles related to settings defined by user from config/settings.txt
    -Rest of styling can be found in:
      --static/css/style-async.css.tpl --> For non critical styles witch will be loaded asynchronously
      --static/css/style-critical.tpl --> For critical CSS rendered inline before the rest of the site

==============================================================================*/#}

{# /* I discontinued this file to work with Tailwind, to facilitate the styling of components.
      Today it only serves to set style variables. */ #}
	
{# /* // Colors */ #}

$primary-color: {{ settings.primary_color }};
$main-foreground: {{ settings.text_color }};
$text-muted: {{ settings.text_muted_color | default('#80807B') }};
$main-background: {{ settings.background_color }};
$accent-color: {{ settings.accent_color }};

{# /* // Font families */ #}

$heading-font: {{ settings.font_headings | raw }};
$body-font: {{ settings.font_rest | raw }};

:root {
  {# /* // Colors */ #}
  --primary-color: #{$primary-color};
  --text-color: #{$main-foreground};
  --text-muted: #{$text-muted};
  --background-color: #{$main-background};
  --accent-color: #{$accent-color};

  {# /* // Font families */ #}
  --font-headings: #{$heading-font};
  --font-body: #{$body-font};
}
