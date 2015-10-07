PHP_ARG_ENABLE(zhandlersocket, whether to enable zhandlersocket, [ --enable-zhandlersocket   Enable Zhandlersocket])

if test "$PHP_ZHANDLERSOCKET" = "yes"; then

	

	if ! test "x" = "x"; then
		PHP_EVAL_LIBLINE(, ZHANDLERSOCKET_SHARED_LIBADD)
	fi

	AC_DEFINE(HAVE_ZHANDLERSOCKET, 1, [Whether you have Zhandlersocket])
	zhandlersocket_sources="zhandlersocket.c kernel/main.c kernel/memory.c kernel/exception.c kernel/hash.c kernel/debug.c kernel/backtrace.c kernel/object.c kernel/array.c kernel/extended/array.c kernel/string.c kernel/fcall.c kernel/extended/fcall.c kernel/require.c kernel/file.c kernel/operators.c kernel/math.c kernel/concat.c kernel/variables.c kernel/filter.c kernel/iterator.c kernel/time.c kernel/exit.c zhandlersocket/zexception.zep.c
	zhandlersocket/logger.zep.c
	zhandlersocket/client.zep.c
	zhandlersocket/command.zep.c
	zhandlersocket/communicationexception.zep.c
	zhandlersocket/connection.zep.c
	zhandlersocket/connectionexception.zep.c
	zhandlersocket/debuglogger.zep.c
	zhandlersocket/duplicateentryexception.zep.c
	zhandlersocket/encoder.zep.c
	zhandlersocket/index.zep.c
	zhandlersocket/log.zep.c
	zhandlersocket/nulllogger.zep.c
	zhandlersocket/whereclause.zep.c
	zhandlersocket/whereclausefilter.zep.c "
	PHP_NEW_EXTENSION(zhandlersocket, $zhandlersocket_sources, $ext_shared,, )
	PHP_SUBST(ZHANDLERSOCKET_SHARED_LIBADD)

	old_CPPFLAGS=$CPPFLAGS
	CPPFLAGS="$CPPFLAGS $INCLUDES"

	AC_CHECK_DECL(
		[HAVE_BUNDLED_PCRE],
		[
			AC_CHECK_HEADERS(
				[ext/pcre/php_pcre.h],
				[
					PHP_ADD_EXTENSION_DEP([zhandlersocket], [pcre])
					AC_DEFINE([ZEPHIR_USE_PHP_PCRE], [1], [Whether PHP pcre extension is present at compile time])
				],
				,
				[[#include "main/php.h"]]
			)
		],
		,
		[[#include "php_config.h"]]
	)

	AC_CHECK_DECL(
		[HAVE_JSON],
		[
			AC_CHECK_HEADERS(
				[ext/json/php_json.h],
				[
					PHP_ADD_EXTENSION_DEP([zhandlersocket], [json])
					AC_DEFINE([ZEPHIR_USE_PHP_JSON], [1], [Whether PHP json extension is present at compile time])
				],
				,
				[[#include "main/php.h"]]
			)
		],
		,
		[[#include "php_config.h"]]
	)

	CPPFLAGS=$old_CPPFLAGS

	PHP_INSTALL_HEADERS([ext/zhandlersocket], [php_ZHANDLERSOCKET.h])

fi
