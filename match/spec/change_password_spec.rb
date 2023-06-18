describe Match do
  describe Match::ChangePassword do
    before do
      stub_const('ENV', { "MATCH_PASSWORD" => '2"QAHg@v(Qp{=*n^' })
    end

    it "deletes decrypted files at the end", requires_security: true do
      git_url = "https://github.com/fastlane/fastlane/tree/master/certificates"
      values = {
        app_identifier: "tools.fastlane.app",
        type: "appstore",
        git_url: git_url,
        shallow_clone: true,
        username: "flapple@something.com"
      }

      config = FastlaneCore::Configuration.create(Match::Options.available_options, values)
      repo_dir = Dir.mktmpdir

      fake_storage = "fake_storage"
      # expect(Match::Storage::GitStorage).to receive(:configure).with(
      #   git_url: git_url,
      #   shallow_clone: true,
      #   skip_docs: false,
      #   git_branch: "master",
      #   git_full_name: nil,
      #   git_user_email: nil,
      #   clone_branch_directly: false
      # ).and_return(fake_storage)
      expect(Match::Storage::GitStorage).to receive(:configure).with(
        api_key: nil,
        api_key_path: nil,
        clone_branch_directly: false,
        git_basic_authorization: nil,
        git_bearer_authorization: nil,
        git_branch: "master",
        git_full_name: nil,
        git_private_key: nil,
        git_url: git_url,
        git_user_email: nil,
        gitlab_project: nil,
        google_cloud_bucket_name: "",
        google_cloud_keys_file: "",
        google_cloud_project_id: "",
        platform: "ios",
        readonly: false,
        s3_access_key: nil,
        s3_bucket: nil,
        s3_object_prefix: nil,
        s3_region: nil,
        s3_secret_access_key: nil,
        s3_session_token: nil,
        shallow_clone: true,
        skip_docs: false,
        skip_google_cloud_account_confirmation: false,
        team_id: nil,
        team_name: nil,
        type: "appstore",
        username: "flapple@something.com"
      ).and_return(fake_storage)

      allow(fake_storage).to receive(:download)
      allow(fake_storage).to receive(:working_directory).and_return(repo_dir)
      allow(fake_storage).to receive(:save_changes!)

      allow(Match::ChangePassword).to receive(:ensure_ui_interactive)
      allow(FastlaneCore::Helper).to receive(:ask_password).and_return("")

      expect(fake_storage).to receive(:clear_changes)

      Match::ChangePassword.update(params: config)
    end
  end
end
