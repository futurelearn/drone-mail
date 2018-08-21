#!/usr/bin/env ruby
#

require 'aws-sdk-ses'

class Mail
  attr :client

  def initialize
    aws_region = Plugin.new.aws_region || 'eu-west-1'
    @client = Aws::SES::Client.new(region: aws_region)
  end

  def encoding
    Plugin.new.encoding || 'UTF-8'
  end

  def htmlbody
    '<h1>Some HTML</h1>'
  end

  def textbody
    'Placeholder text'
  end

  def payload
    {
      destination: {
        to_addresses: [
          Plugin.new.recipient,
        ],
      },
      message: {
        body: {
          html: {
            charset: encoding,
            data: htmlbody,
          },
          text: {
            charset: encoding,
            data: textbody,
          },
        },
        subject: {
          charset: encoding,
          data: subject,
        },
      },
      source: Plugin.new.sender,
    }
  end

  def send
    begin
      client.send_email(payload)
    rescue Aws::SES::Errors::ServiceError => error
      puts "Email not sent! Error message: #{error}"
    end
  end
end

class Drone
  # These are environment variables set by Drone itself
  def drone_env(name)
    ENV.fetch("DRONE_#{name.upcase}", nil)
  end

  def author
    drone_env("commit_author")
  end

  def branch
    drone_env("commit_branch")
  end

  def build
    drone_env("build_number")
  end

  def status
    drone_env("job_status")
  end

  def started
    drone_env("build_started")
  end

  def finished
    drone_env("build_finished")
  end

  def link
    drone_env("build_link")
  end

  def repo_name
    drone_env("repo")
  end

  def repo_owner
    drone_env("repo_owner")
  end

  def sha
    drone_env("commit_sha")
  end

  def commit_message
    drone_env("commit_message")
  end

  def commit_link
    drone_env("commit_link")
  end

end

class Plugin
  # Any custom parameters
  def set_parameter(parameter_name, required = true)
    parameter = "PLUGIN_" + parameter_name.upcase

    if required && ENV[parameter].nil?
      abort("Must set #{parameter}")
    end

    return false if ENV[parameter].nil?

    ENV[parameter]
  end

  def recipient
    set_parameter("recipient")
  end

  def sender
    set_parameter("sender")
  end

  def subject
    set_parameter("subject", false)
  end

  def aws_region
    set_parameter("aws_region", false)
  end
end

Mail.new.send
