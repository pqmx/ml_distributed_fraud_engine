script_folder="/Users/prestonmamaril/fraud-detection-engine"
echo "echo Restoring environment" > "$script_folder/deactivate_conanrunenv-release-armv8.sh"
for v in GRPC_DEFAULT_SSL_ROOTS_FILE_PATH OPENSSL_MODULES
do
   is_defined="true"
   value=$(printenv $v) || is_defined="" || true
   if [ -n "$value" ] || [ -n "$is_defined" ]
   then
       echo export "$v='$value'" >> "$script_folder/deactivate_conanrunenv-release-armv8.sh"
   else
       echo unset $v >> "$script_folder/deactivate_conanrunenv-release-armv8.sh"
   fi
done

export GRPC_DEFAULT_SSL_ROOTS_FILE_PATH="/Users/prestonmamaril/.conan2/p/b/grpc7a24ccbd165c9/p/res/grpc/roots.pem"
export OPENSSL_MODULES="/Users/prestonmamaril/.conan2/p/opensf16b602a2157d/p/lib/ossl-modules"