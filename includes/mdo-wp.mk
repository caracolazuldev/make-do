include mdo-require.mk
# # #
# Gnu Make functions for Wordpress developers
#
# REQUIRES:
# - WEB_ROOT
# - WP_PLUGINS_SRC [./]
# - WP_PLUGINS_DIR [${WEB_ROOT}wp-content/plugins/] 
#
# WP INSTALL REQUIRES:
# - DB_CMS_DB
# - DB_USER
# - DB_PASSWORD
# - CMS_URL
# - CMS_ADMIN_USER
# - CMS_ADMIN_PASSWORD
# - CMS_ADMIN_EMAIL
#

WEB_USER ?= www-data
WP_PLUGINS_SRC ?= ./
WP_PLUGINS_DIR ?= ${WEB_ROOT}wp-content/plugins/# where to deploy wordpress plugins

wp-cli-bin := $(shell command -v wp 2>/dev/null)
ifndef wp-cli-bin
$(error wp-cli NOT FOUND)
endif

# Don't run wp as root:
WP_CLI = sudo -u ${WEB_USER} ${wp-cli-bin} --path=${WEB_ROOT} --skip-plugins --skip-themes

define wp-purge-plugin
	- ${WP_CLI} plugin uninstall --deactivate ${1}
	- ( ${WP_CLI} plugin delete ${1}  || rm -r ${WP_PLUGINS_DIR}$(strip ${1}) )
endef

define wp-purge-theme
	[ -d ${WEB_ROOT}wp-content/themes/$(strip ${1}) ] || [ -L ${WEB_ROOT}wp-content/themes/$(strip ${1}) ] && rm -rf ${WEB_ROOT}wp-content/themes/$(strip ${1}) || true
endef

# # #
# Meant for use in a plugin build-make, probably not a deployment-util.
# Line-continuations used to avoid suprises when used in a recipe.
#
define wp-plugin-archive
	([ -d  dist ] && rm -rf dist || true); \
	mkdir -p dist/$(strip ${1}); \
	rsync -a --delete --copy-links \
	--exclude .git --exclude .gitignore \
	--exclude phpunit --exclude tests \
	--exclude '*.env' --exclude '*.conf' \
	--exclude dist \
	. dist/$(strip ${1})/; \
	cd dist &&  zip -qr $(strip ${1}).zip $(strip ${1})/; \
	rm -rf dist/$(strip ${1})/;
endef

# # #
# Expects the default target to create a plugin distro zip
#
plugin-%.zip:
	$(eval repo := '$(shell find ${WP_PLUGINS_SRC} -type d -name ${*})')
	#
	# WARNING: guessed plugin location ${repo}
	# 
	$(MAKE) -C ${repo}

define wp-deploy-plugin
	$(eval plugin := '$(shell find ${WP_PLUGINS_SRC} -name $(strip ${1}).zip)')
	#
	# NOTICE: found plugin-distro-zip: ${plugin}
	#
	- $(WP_CLI) plugin delete ${1} || rm -r $(strip ${WP_PLUGINS_DIR})$(strip ${1})
	$(WP_CLI) plugin install --activate ${plugin}
endef

# # #
# for publicly listed plugins
#
WP_INSTALL_PLUGIN := $(WP_CLI) plugin install --activate 

define wp-deploy-theme
	$(eval theme := '$(shell find ${WP_PLUGINS_SRC} -name $(strip ${1}).zip)')
	$(call wp-purge-theme,${1})
	@# activate a distro theme:
	@#$(WP_CLI) theme activate twentynineteen
	# deploy and activate the theme
	#rsync -r ${WP_PLUGINS_SRC}${1} ${WEB_ROOT}wp-content/themes/
	$(WP_CLI) --skip-themes theme install --activate --force ${theme}
endef

define WP_DEBUG_PATCH
--- wp-config.php	2019-05-29 19:05:26.689652862 -0400
+++ wp-config.php	2019-05-29 19:05:29.241667777 -0400
@@ -18,6 +18,10 @@
  * @package WordPress
  */
 
+define( 'WP_DEBUG', true );
+define( 'WP_DEBUG_DISPLAY', false );
+define( 'WP_DEBUG_LOG', true );
+
 // ** MySQL settings ** //
 /** The name of the database for WordPress */
 define( 'DB_NAME', 'msa_cms_dev' );

endef
export WP_DEBUG_PATCH

# to create a default .htaccess file:
# echo "$$WP_BASE_HTACCESS" > ${WEB_ROOT}.htaccess
define WP_BASE_HTACCESS
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>

# END WordPress
endef
export WP_BASE_HTACCESS

define wp-permalink-postname
	$(WP_CLI) option update permalink_structure '/%postname%'
endef

# # # 
# Targets
# # #

CACHED_DG := ${.DEFAULT_GOAL}

wp-enable-debug: | require-env-WEB_ROOT
	- cd ${WEB_ROOT} && echo "$$WP_DEBUG_PATCH" | patch -f -F 0
	touch ${WEB_ROOT}wp-content/debug.log

wp-debug-log: enable-wp-debug | require-env-WEB_ROOT
	cd ${WEB_ROOT} && tail -fn100 wp-content/debug.log

wp-file-acl: | require-env-WEB_ROOT
	@# first clear facls set:
	sudo setfacl -Rx 'g:www-data,d:g:www-data' ${WEB_ROOT}wp-content
	sudo setfacl -Rm 'm:rwx,d:u::rwx,d:g:www-data:rwX,u::rwX,g:www-data:rwX' ${WEB_ROOT}wp-content

# run wp as current user (bypass WP_CLI)
wp-install: WP_CLI = ${wp-cli-bin} --path=${WEB_ROOT}
wp-install: ${WEB_ROOT} | require-env-DB_CMS_DB require-env-DB_USER require-env-DB_PASSWORD require-env-CMS_URL require-env-CMS_ADMIN_USER require-env-CMS_ADMIN_PASSWORD require-env-CMS_ADMIN_EMAIL
	${WP_CLI} core download
	# ${WP_CLI} core config
	@${WP_CLI} core config --dbname=${DB_CMS_DB} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD}
	${WP_CLI} db create
	# ${WP_CLI} core install
	@${WP_CLI} core install --url="${CMS_URL}" --title="${CMS_TITLE}" --admin_user="${CMS_ADMIN_USER}" --admin_password="${CMS_ADMIN_PASSWORD}" --admin_email="${CMS_ADMIN_EMAIL}"
	echo "$$WP_BASE_HTACCESS" > ${WEB_ROOT}.htaccess
	
wp-destroy: | require-env-WEB_ROOT require-env-DB_CMS_DB
	- $(WP_CLI) db query 'DROP DATABASE IF EXISTS ${DB_CMS_DB}'
	- rm -rf ${WEB_ROOT}

# # #
# END Targets
# Rset .DEFAULT_GOAL
.DEFAULT_GOAL := ${CACHED_DG}
