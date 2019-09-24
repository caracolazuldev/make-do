# # #
# Gnu Make functions for Wordpress developers
#
# REQUIRES:
# - WP_PLUGINS_SRC
# - WEB_ROOT
# - WP_PLUGINS_DIR

WEB_USER ?= www-data

wp-cli-bin := $(shell command -v wp 2>/dev/null)
ifndef wp-cli-bin
$(error wp-cli NOT FOUND)
endif

# Don't run wp as root:
WP_CLI = sudo -u ${WEB_USER} ${wp-cli-bin} --path=${WEB_ROOT}

WP_PLUGINS_SRC ?= ./

define purge-wp-plugin
	- cd ${WEB_ROOT} && ${WP_CLI} plugin deactivate ${@} 
	- cd ${WEB_ROOT} && ${WP_CLI} plugin uninstall ${@}
	- cd ${WEB_ROOT} && ( ${WP_CLI} plugin delete ${@}  || rm -r ${WP_PLUGINS_DIR}${@} )
endef

# # #
# Meant for use in a plugin build-make, probably not a deployment-util.
#
define wp-plugin-archive
	[ -d  dist ] && rm -rf dist || true
	mkdir -p dist/${@}
	rsync -a --delete --copy-links \
	--exclude .git --exclude .gitignore \
	--exclude phpunit --exclude tests \
	--exclude '*.env' --exclude '*.conf' \
	--exclude dist \
	. dist/${@}/
	cd dist &&  zip -qr ${@}.zip ${@}/
	rm -rf dist/${@}/
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

define deploy-wp-plugin
	# $(shell find . -name ${@}.zip)
	$(eval plugin := '$(shell find ${WP_PLUGINS_SRC} -name ${@}.zip)')
	#
	# WARNING: found plugin distro-zip, ${plugin}
	#
	cp ${plugin} ${WP_PLUGINS_DIR}
	cd ${WP_PLUGINS_DIR} && wp plugin install --activate ${@}.zip
	rm ${WP_PLUGINS_DIR}${@}.zip
endef

# # #
# for publicly listed plugins
#
define install-public-wp-plugin
	cd ${WEB_ROOT} && wp plugin install --activate ${@}
endef

define deploy-theme
	@# for development: start by deleting the theme, in-case there are errors in the last deployment.
	[ -d ${WEB_ROOT}wp-content/themes/${@} ] && cd ${WEB_ROOT} && rm -rf ${WEB_ROOT}wp-content/themes/${@} || true
	@# activate a distro theme:
	cd ${WEB_ROOT} && wp theme activate twentynineteen
	# deploy and activate the theme
	rsync -r ${WP_PLUGINS_SRC}${@} ${WEB_ROOT}wp-content/themes/
	cd ${WEB_ROOT} && wp theme activate ${@}
endef

define DEBUG_PATCH
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
export DEBUG_PATCH

# # # 
# Targets
# # #

CACHED_DG := ${.DEFAULT_GOAL}

wp-enable-debug:
	- cd ${WEB_ROOT} && echo "$$DEBUG_PATCH" | patch -f -F 0
	touch ${WEB_ROOT}wp-content/debug.log

wp-debug-log: enable-wp-debug
	cd ${WEB_ROOT} && tail -fn100 wp-content/debug.log

wp-file-acl:
	@# first clear facls set:
	sudo setfacl -Rx 'g:www-data,d:g:www-data' ${PROJ_ROOT}htdocs/wp-content
	sudo setfacl -Rm 'm:rwx,d:u::rwx,d:g:www-data:rwX,u::rwX,g:www-data:rwX' ${PROJ_ROOT}htdocs/wp-content

# run wp as current user (bypass WP_CLI)
wp-install: WP_CLI = ${wp-cli-bin} --path=${WEB_ROOT}
wp-install: ${WEB_ROOT}
	${WP_CLI} core download
	# ${WP_CLI} core config
	@${WP_CLI} core config --dbname=${DB_CMS_DB} --dbuser=${DB_USER} --dbpass=${DB_PASSWORD}
	${WP_CLI} db create
	# ${WP_CLI} core install
	@${WP_CLI} core install --url="${CMS_URL}" --title="${CMS_TITLE}" --admin_user="${CMS_ADMIN_USER}" --admin_password="${CMS_ADMIN_PASSWORD}" --admin_email="${CMS_ADMIN_EMAIL}"
	
wp-destroy:
	- $(WP_CLI) db query 'DROP DATABASE IF EXISTS ${DB_CMS_DB}'
	- rm -rf ${WEB_ROOT}

# # #
# END Targets
# Rset .DEFAULT_GOAL
.DEFAULT_GOAL := ${CACHED_DG}
