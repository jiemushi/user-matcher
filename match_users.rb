require 'csv'

class UserMatcher
  def initialize(matching_types)
    @matching_types = matching_types
    @user_data = []
    @normalized_phones = []
    @user_ids = {}
  end

  def process_file(input_file)
    parse_csv(input_file)

    @user_data.each_index { |i| @user_ids[i] = i }

    find_matches

    create_output(input_file)
  end

  private

  def parse_csv(input_file)
    CSV.foreach(input_file, headers: true) do |row|
      @user_data << row
      @normalized_phones << normalize_phones(row)
    end
  end

  def normalize_phones(row)
    {
      'Phone' => row['Phone']&.strip&.gsub(/[^0-9]/, ''),
      'Phone1' => row['Phone1']&.strip&.gsub(/[^0-9]/, ''),
      'Phone2' => row['Phone2']&.strip&.gsub(/[^0-9]/, '')
    }
  end

  def build_email_index
    index = {}
    @user_data.each_with_index do |row, i|
      emails = [row['Email']&.strip&.downcase, row['Email1']&.strip&.downcase, row['Email2']&.strip&.downcase].compact
      emails.each do |email|
        index[email] ||= []
        index[email] << i
      end
    end

    index
  end

  def build_phone_index
    index = {}
    @normalized_phones.each_with_index do |phones, i|
      phones.values.compact.each do |phone|
        index[phone] ||= []
        index[phone] << i
      end
    end

    index
  end

  def find_matches
    puts "Finding matches..."

    @matching_types.each do |type|
      case type
      when 'email'
        email_index = build_email_index
        process_index(email_index)
      when 'phone'
        phone_index = build_phone_index
        process_index(phone_index)
      end
    end
  end

  def process_index(index)
    index.each do |_, user_indices|
      next if user_indices.size < 2

      root_id = user_indices.map { |i| @user_ids[i] }.min

      # Update all users in this group to point to the root
      user_indices.each do |i|
        if @user_ids[i] != root_id
          old_id = @user_ids[i]
          @user_data.each_index do |j|
            @user_ids[j] = root_id if @user_ids[j] == old_id
          end
        end
      end
    end
  end

  def create_output(input_file)
    output_file = input_file.gsub('.csv', '_output.csv')
    
    CSV.open(output_file, 'w') do |csv|
      puts "Creating output file..."

      headers = ['user_id'] + @user_data.first.headers
      csv << headers

      @user_data.each_with_index do |row, index|
        user_id = @user_ids[index] + 1
        csv << [user_id] + row.fields
      end
    end

    puts "\e[32mFile processed. Output written to #{output_file}.\e[0m"
  end
end

if __FILE__ == $0
  if ARGV.length < 2
    puts "\e[31mExecute: ruby match_users.rb <matching_type1> [matching_type2] <csv_file>\e[0m"
    puts "\e[31mExample: ruby match_users.rb email phone input1.csv\e[0m"
    exit 1
  end

  matching_types = ARGV[0...-1]

  unless matching_types.include?('email') || matching_types.include?('phone')
    puts "\e[31mOnly phone or email matching is supported.\e[0m"
    exit 1
  end

  input_file = ARGV.last

  unless File.exist?(input_file) && File.extname(input_file).downcase == '.csv'
    puts "\e[31mInput file is required and should be a CSV file.\e[0m"
    exit 1
  end

  matcher = UserMatcher.new(matching_types)
  matcher.process_file(input_file)
end
