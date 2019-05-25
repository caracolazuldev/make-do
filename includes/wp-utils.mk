
# # #
# Utils for working with Wordpress Instances
# Some environment variables required: use the source.
# # #


define purge-wp-plugin
        - cd ${WEB_ROOT} && wp plugin deactivate ${@}
        - cd ${WEB_ROOT} && wp plugin uninstall ${@}
        - cd ${WEB_ROOT} && wp plugin delete ${@}
endef

define create-wp-plugin-dist
        - rm ${REPOS}/${@}.zip 2>/dev/null
        cd ${REPOS} && zip -qr ${@}.zip ${@} -x \*/.git/\*
endef

define deploy-wp-plugin
        cp ${REPOS}/${@}.zip ${WP_PLUGINS}
        cd ${WP_PLUGINS} && wp plugin install --activate ${@}.zip
        rm ${WP_PLUGINS}/${@}.zip
endef

define install-public-wp-plugin
        cd ${WEB_ROOT} && wp plugin install --activate ${@}
endef

define deploy-theme
        @# for development: start by deleting the theme, in-case there are errors in the last deployment.
        [ -d ${WEB_ROOT}/wp-content/themes/${@} ] && cd ${WEB_ROOT} && rm -rf ${WEB_ROOT}/wp-content/themes/${@} || true
        @# activate a distro theme:
        cd ${WEB_ROOT} && wp theme activate twentynineteen
        # deploy and activate the theme
        rsync -r repos/${@} ${WEB_ROOT}/wp-content/themes/
        cd ${WEB_ROOT} && wp theme activate ${@}
endef
