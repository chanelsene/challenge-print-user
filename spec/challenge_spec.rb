# frozen_string_literal: true

RSpec.describe Challenge do
  describe 'printUsers' do
    before(:all) do
      company_path = File.expand_path('../spec/resources/companies.json', __dir__)
      user_path = File.expand_path('../spec/resources/users.json', __dir__)
      @output_path = File.expand_path('../spec/test_output.txt', __dir__)
      Challenge.print_users(company_path, user_path, @output_path)
    end
    after(:all) do
      if File.exist?(@output_path)
        begin
          File.delete(@output_path)
          puts 'File successfully deleted.'
        rescue Errno::EACCES
          puts 'Permission denied.'
        rescue StandardError => e
          puts "An error occurred while deleting file #{@output_path}: #{e.message}"
        end
      else
        puts 'File does not exist.'
      end
    end

    context 'when it completes successfully' do
      it 'creates a file' do
        file = File.read(@output_path)
        expect(file).not_to be nil
      end
    end

    context 'when no users have email_status on' do
      it 'provides an empty list of emailed users' do
        puts "PATH IS #{@output_path}"
        lines = File.read(@output_path).split(/\r?\n/)
        index = lines.find_index('Users Emailed:')
        expect(lines[index + 1]).to include 'Users Not Emailed:'
      end
    end

    context 'when some users have email_status on' do
      it 'provides a list of emailed users' do
        lines = File.read(@output_path).split(/\r?\n/)
        expect(lines[15]).to include 'Boberson, Bob'
        expect(lines[18]).to include 'Boberson, John'
        expect(lines[21]).to include 'Simpson, Edgar'
      end
    end

    context 'when a company has no user' do
      it 'does not add the company' do
        lines = File.read(@output_path).split(/\r?\n/)
        index = lines.find_index('Red Deer Inc.')
        expect(index).to be nil
      end
    end

    context 'when tokens are calculated' do
      it 'provides the correct token amount' do
        lines = File.read(@output_path).split(/\r?\n/)
        expect(lines[16]).to include '23'
        expect(lines[17]).to include '60'
      end
    end
  end
end
