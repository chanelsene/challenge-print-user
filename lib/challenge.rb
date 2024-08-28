# frozen_string_literal: true

require_relative 'challenge/version'
require 'json'

# Module which lists users who have received token topup, grouped by comapny and ordered by last name
module Challenge
  class Error < StandardError; end
  def self.print_users(company_file, user_file, output_path)
    companies = JSON.parse(File.read(company_file))
    users = JSON.parse(File.read(user_file))
    active_users = users.select { |item| item['active_status'] }
    topups = Array.new(companies.length) { [] }
    # Get the active users
    active_users.each do |user|
      company_index = user['company_id'] - 1
      user['sent'] = companies[company_index]['email_status'] && user['email_status']
      topups[company_index].push(user)
    end

    # Order and list users for each company
    begin
      file = File.open(output_path, 'w')
      companies.each_with_index do |_, i|
        next if topups[i].empty?

        file.puts("Company Id: #{companies[i]['id']}")
        file.puts("Company name: #{companies[i]['name']}")
        topups[i].sort_by! { |a| a['last_name'] }
        file.puts('Users Emailed:')
        sent = topups[i].select { |user| user['sent'] }
        email_users(sent, file, companies[i]['top_up'])
        file.puts('Users Not Emailed:')
        unsent = topups[i].reject { |user| user['sent'] }
        email_users(unsent, file, companies[i]['top_up'])
        file.puts("\tTotal amount of top ups for #{companies[i]['name']}: #{companies[i]['top_up'] * topups[i].length}")
        file.puts
      end
    rescue Errno::EACCES
      puts 'Access denied. Unable to create the output file. Please re-run the script with the correct permissions.'
    rescue StandardError => e
      puts "Error while adding users to #{output_path}: #{e.message}."
    ensure
      file&.close
    end
  end

  # Helper method to print user info
  def self.email_users(arr, file, top_up)
    arr.each do |user|
      file.puts("\t#{user['last_name']}, #{user['first_name']}, #{user['email']}")
      file.puts("\t\tPrevious Token Balance: #{user['tokens']}")
      file.puts("\t\tNew Token Balance: #{user['tokens'] + top_up}")
    end
  end
end

company_path = File.expand_path('../assets/companies.json', __dir__)
user_path = File.expand_path('../assets/users.json', __dir__)
output_path = File.expand_path('output.txt', __dir__)
Challenge.print_users(company_path, user_path, output_path)
