#!/usr/bin/env ruby
require 'json'
require 'date'

class Summary
  def initialize
    @summary = {}
  end

  def add(date)
    @summary[date].nil? ? @summary[date] = 1 : @summary[date] += 1
  end

  def output
    @summary.sort.map { |line| "#{line[0]}: #{line[1]} images" }.join("\n")
  end
end

def image_redis?(image)
  image['imageTags'].join("\t").match?(/redis/)
end

def image_in_use?(image)
  image['imageTags'].join("\t").match?(ENV.fetch('GITHUB_SHA', '-'))
end

def image_out_of_date?(image)
  delete_if_older_than = 2 # days
  date_pushed = DateTime.strptime(image['imagePushedAt'].to_s, '%s')
  @summary.add(date_pushed.to_date.to_s)
  age_in_days = (DateTime.now - date_pushed).to_i
  age_in_days > delete_if_older_than
end

def image_deletable(image)
  [image_out_of_date?(image), !image_in_use?(image), !image_redis?(image)].all?
end

repo = 'laa-apply-for-legal-aid/laa-apply-bot'
aws_prefix = 'aws --region eu-west-2 ecr'
puts 'Identifying images to delete'
json_output = `#{aws_prefix} describe-images --repository-name #{repo} --output json`
images = JSON.parse(json_output)['imageDetails']

images_to_delete = []
@summary = Summary.new
images.each do |i|
  images_to_delete << i if image_deletable(i)
end

if images_to_delete.empty?
  puts 'Nothing to delete'
else
  puts 'Deleting images'
  images_to_delete.each_slice(100) do |batch|
    image_ids = batch.map { |i| "imageDigest=#{i['imageDigest']}" }.join(' ')
    puts "I want to delete #{image_ids}"
    puts `#{aws_prefix} batch-delete-image --repository-name #{repo} --image-ids #{image_ids}`
  end

end
puts @summary.output
puts 'Done!'
