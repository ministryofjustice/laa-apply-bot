module Portal
  class NameErrorMessage
    def initialize(users)
      @user_list = users
    end

    def call
      build_name_errors.chomp
    end

    def self.call(users)
      new(users).call
    end

    private

    def build_name_errors
      result = ''
      @user_list.each do |name|
        result += good_name(name) if name.errors.nil?
        result += bad_name(name) if name.errors.present?
      end
      result
    end

    def good_name(name)
      "*#{name.display_name}* :yep:\n"
    end

    def bad_name(name)
      "*#{name.display_name}* :nope: #{name.errors}\n"
    end
  end
end
