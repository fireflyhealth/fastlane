require_relative 'module'

require_relative 'storage'
require_relative 'encryption'

module Match
  # These functions should only be used while in (UI.) interactive mode
  class ChangePassword
    def self.update(params: nil)

      ensure_ui_interactive

      new_password = FastlaneCore::Helper.ask_password(message: "New passphrase for Git Repo: ", confirm: true)

      # Choose the right storage and encryption implementations
      storage = Storage.for_mode(params[:storage_mode], {
        git_url: params[:git_url],
        shallow_clone: params[:shallow_clone],
        skip_docs: params[:skip_docs],
        git_branch: params[:git_branch],
        git_full_name: params[:git_full_name],
        git_user_email: params[:git_user_email],
        clone_branch_directly: params[:clone_branch_directly]
        git_private_key: params[:git_private_key],
        git_basic_authorization: params[:git_basic_authorization],
        git_bearer_authorization: params[:git_bearer_authorization],
        clone_branch_directly: params[:clone_branch_directly],
        type: params[:type].to_s,
        platform: params[:platform].to_s,
        google_cloud_bucket_name: params[:google_cloud_bucket_name].to_s,
        google_cloud_keys_file: params[:google_cloud_keys_file].to_s,
        google_cloud_project_id: params[:google_cloud_project_id].to_s,
        skip_google_cloud_account_confirmation: params[:skip_google_cloud_account_confirmation],
        s3_bucket: params[:s3_bucket],
        s3_region: params[:s3_region],
        s3_access_key: params[:s3_access_key],
        s3_session_token: params[:s3_session_token],
        s3_secret_access_key: params[:s3_secret_access_key],
        s3_object_prefix: params[:s3_object_prefix],
        gitlab_project: params[:gitlab_project],
        readonly: params[:readonly],
        username: params[:username],
        team_id: params[:team_id],
        team_name: params[:team_name],
        api_key_path: params[:api_key_path],
        api_key: params[:api_key]
      })
      storage.download

      encryption = Encryption.for_storage_mode(params[:storage_mode], {
        git_url: params[:git_url],
        working_directory: storage.working_directory
      })
      encryption.decrypt_files

      encryption.clear_password
      encryption.store_password(new_password)

      message = "[fastlane] Changed passphrase"
      files_to_commit = encryption.encrypt_files(password: new_password)
      storage.save_changes!(files_to_commit: files_to_commit, custom_message: message)
    ensure
      storage.clear_changes if storage
    end

    def self.ensure_ui_interactive
      raise "This code should only run in interactive mode" unless UI.interactive?
    end

    private_class_method :ensure_ui_interactive
  end
end
