require "spec_helper"

RSpec.describe Growi::Client do

  # Page path for test
  # @note Test page is not removed after test because removing page is not permitted throw API.
  let(:test_page_path) { '/tmp/growi-client テストページ'  }
  let(:growi_client)   { GrowiClient.new(growi_url: ENV['GROWI_URL'],
                                         access_token: ENV['GROWI_ACCESS_TOKEN']) }

  describe '# GrowiClient\'s basic attributes and methods :' do
    # Test for VERSION
    it "check version number is exist" do
      expect(Growi::Client::VERSION).not_to be nil
    end
  end

  describe '# API related Growi pages :' do
    # Test for function to get page list
    it "get list of page" do
      req = GApiRequestPagesList.new path_exp: '/'
      expect(growi_client.request(req).ok).to eq true
    end
  
    # Test for function to get page
    it "get page" do
      aggregate_failures 'some pattern to get page' do
        # get page specified path
        req = GApiRequestPagesGet.new path: '/'
        expect(growi_client.request(req).ok).to eq true
  
        # get page specified page_id
        req = GApiRequestPagesGet.new page_id: growi_client.page_id(path_exp: '/')
        expect(growi_client.request(req).ok).to eq true
  
        # get page specified path and revision_id
        reqtmp = GApiRequestPagesList.new path_exp: '/'
        ret = growi_client.request(reqtmp)
        page = ret&.data&.find{ |page| page.path == '/' }
        req = GApiRequestPagesGet.new path: page.path, revision_id: page.revision._id
        expect(growi_client.request(req).ok).to eq true
      end
    end
  
    # Test for function to create page
    it "create page" do
      body = "# growi-client\n"
      req = GApiRequestPagesCreate.new path: test_page_path,
              body: body
      expect(growi_client.request(req).ok).to eq true
    end

    # Test for function to update page
    it "update page" do
      test_cases = [nil, GrowiPage::GRANT_PUBLIC, GrowiPage::GRANT_RESTRICTED,
                    GrowiPage::GRANT_SPECIFIED, GrowiPage::GRANT_OWNER]
      page_id = growi_client.page_id(path_exp: test_page_path)
  
      body = "# growi-client\n"
      test_cases.each do |grant| 
        body = body + grant.to_s
        req = GApiRequestPagesUpdate.new page_id: page_id,
                body: body, grant: grant
        expect(growi_client.request(req).ok).to eq true
      end
    end
  
    # Test for function to get the page list, which is seen
    it "get seen pages" do
      page_id = growi_client.page_id(path_exp: test_page_path)
      req = GApiRequestPagesSeen.new page_id: page_id
      expect(growi_client.request(req).ok).to eq true
    end
  
    # Test for function to react LIKE
    it "add LIKE reaction" do
      page_id = growi_client.page_id(path_exp: test_page_path)
      req = GApiRequestLikesAdd.new page_id: page_id
      expect(growi_client.request(req).ok).to eq true
    end
  
    # Test for function to cancel LIKE reaction
    it "remove LIKE reaction" do
      page_id = growi_client.page_id(path_exp: test_page_path)
      req = GApiRequestLikesRemove.new page_id: page_id
      expect(growi_client.request(req).ok).to eq true
    end
  
    # Test for function to set update post
    it "update post" do
      req = GApiRequestPagesUpdatePost.new path: test_page_path
      expect(growi_client.request(req).ok).to eq true
    end

    # Test for function to check page existence
    # @todo Assure page existence.
    #       (ex. path '/' is not promises existence, and path '/tmp/#####FAKE_PATH#####' is also)
    it "check page existence" do
      aggregate_failures 'exist page, and not exist page' do
        expect(growi_client.page_exist?( path_exp: test_page_path )).to eql(true)
        expect(growi_client.page_exist?( path_exp: '/tmp/#####FAKE_PAGE#####' )).to eql(false)
      end
    end
  end

  describe '# API related Growi attachments :' do

    let(:attachment_name) { '添付ファイルテスト.txt' }
    let(:attachment_body) { '添付ファイルテスト' }

    # Test for function to get attachment list
    it "get attachments list" do
      page_id = growi_client.page_id(path_exp: test_page_path)
      req = GApiRequestAttachmentsList.new page_id: page_id
      expect(growi_client.request(req).ok).to eq true
    end
 
    # Test for function to add attachment
    it "add attachment" do

      # 添付ディレクトリ配下にファイルを作成してから添付ファイルをアップロード
      Dir.mktmpdir do |tmp_dir|
        attachment_file_name = File.join(tmp_dir, attachment_name)

        File.open(attachment_file_name, 'w') do |tmp_file|
          tmp_file.binmode
          tmp_file.write(attachment_body)
        end

        File.open(attachment_file_name, 'r') do |tmp_file|
          page_id = growi_client.page_id(path_exp: test_page_path)
          req = GApiRequestAttachmentsAdd.new page_id: page_id, file: tmp_file
          expect(growi_client.request(req).ok).to eq true
        end
      end
    end
  
    # Test for function to check attachment existence
    it "check attachment existence" do
      expect(growi_client.attachment_exist?(path_exp: test_page_path, 
                                            attachment_name: attachment_name)).to eql(true)
    end
 
    # Test for function to get attachment info
    it "get attachment info" do
      a = growi_client.attachment(path_exp: test_page_path, attachment_name: attachment_name)
      expect(a.originalName).to eq attachment_name
    end

    # Test for function to remove attachment file
    it "remove attachment" do
      page_id = growi_client.page_id(path_exp: test_page_path)
      reqtmp = GApiRequestAttachmentsList.new page_id: page_id
      ret = growi_client.request(reqtmp)
      attachment_id = ret.data[0]._id
      req = GApiRequestAttachmentsRemove.new attachment_id: attachment_id
      expect(growi_client.request(req).ok).to eq true
    end
  end
end
