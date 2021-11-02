describe Fastlane::Actions::XiaomiDevuploadAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The xiaomi_devupload plugin is working!")

      Fastlane::Actions::XiaomiDevuploadAction.run(nil)
    end
  end
end
