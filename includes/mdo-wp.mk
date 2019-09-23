include mdo-require.mk

# # #
# Gnu Make functions for Wordpress developers
#

$(call require-env,WEB_ROOT)

define purge-wp-plugin
	- cd ${WEB_ROOT} && wp plugin deactivate ${@} 
	- cd ${WEB_ROOT} && wp plugin uninstall ${@}
	- cd ${WEB_ROOT} && ( wp plugin delete ${@}  || rm -r ${WP_PLUGINS}${@} )
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
	$(eval repo := '$(shell find . -type d -name ${*})')
	#
	# WARNING: guessed plugin location ${repo}
	# 
	$(MAKE) -C ${repo}

define deploy-wp-plugin
	# $(shell find . -name ${@}.zip)
	$(eval plugin := '$(shell find . -name ${@}.zip)')
	#
	# WARNING: found plugin distro-zip, ${plugin}
	#
	cp ${plugin} ${WP_PLUGINS}
	cd ${WP_PLUGINS} && wp plugin install --activate ${@}.zip
	rm ${WP_PLUGINS}${@}.zip
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
	rsync -r repos/${@} ${WEB_ROOT}wp-content/themes/
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

enable-wp-debug:
	- cd ${WEB_ROOT} && echo "$$DEBUG_PATCH" | patch -f -F 0
	touch ${WEB_ROOT}wp-content/debug.log

wp-debug-log: enable-wp-debug
	cd ${WEB_ROOT} && tail -fn100 wp-content/debug.log

# # #
# END Targets
# Rset .DEFAULT_GOAL
.DEFAULT_GOAL := ${CACHED_DG}
