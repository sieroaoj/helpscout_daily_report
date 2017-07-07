require 'helpscout'
require 'rest_client'  # using this modified version https://github.com/sieroaoj/helpscout/tree/add_tags

#day_string=Date.today.prev_day.strftime("%Y-%m-%d")
day_string=Date.today.strftime("%Y-%m-%d")
tstart = "#{day_string}T00:00:00Z"
tend = "#{day_string}T23:59:59Z"


HELPSCOUT_API_KEY = ""

class MessageContainer
  attr_accessor :mail_string

  def initialize
    @mail_string = ""
  end

  def print_conversation(conversation, print_status: true, print_created_at: false)
     c = conversation
     link = "https://secure.helpscout.net/conversation/#{c.id}/#{c.number}/"
     save_mail_string "&nbsp;&nbsp;<a href=\"#{link}\">"
     if print_status
       save_mail_string "#{c.status} - "
     end
     if print_created_at
       save_mail_string "#{c.createdAt.strftime("%Y-%m-%d")} - "
     end
     save_mail_string "#{c.owner} - #{c.customer}: #{c.subject}</a><br />"
  end


  def save_mail_string(partial_string)
    @mail_string << partial_string
  end

  def message
    @mail_string
  end
end

mc = MessageContainer.new

title = "helpdesk@domain.example.com daily summary of #{day_string}"
mc.save_mail_string "<h1>#{title}</h1><br/><br/>"

helpscout = HelpScout::Client.new(HELPSCOUT_API_KEY)

# users = helpscout.users
# users.each do |u|
#   mc.save_mail_string "#{u.to_s}"
#   user_report = helpscout.get_user_report(u,tstart,tend)

#   mc.save_mail_string "  conversationsCreated: #{user_report.current['conversationsCreated']}<br/>"
#   mc.save_mail_string "  conversationsClosed: #{user_report.current['closed']}<br/><br/>"
# end

#mc.save_mail_string "<br/><b>Conversations by Tag:</b><br/>"

mailboxes = helpscout.mailboxes
mailboxId = mailboxes[0].id #only one mailbox

tags = helpscout.tags
ignore_tags = ['outbound','inbound','info']

tags.each do |tag|
  unless ignore_tags.include?(tag.tag)
    conversations = helpscout.conversations(mailboxId,"all", 0,tstart,tag)

    if conversations.size > 0
      mc.save_mail_string "<br/><b>#{tag}:</b><br/>"
      conversations.each {|c| mc.print_conversation c }
    end
  end
end


mc.save_mail_string "<br/><br/>"
conversations = helpscout.conversations(mailboxId,"active", 0,"2016-01-01T00:00:00Z",nil)
if conversations.size > 0
    mc.save_mail_string "<br/><b>Active: #{conversations.size}</b><br/>"
    conversations.each {|c| mc.print_conversation(c, print_status: false, print_created_at: true) }
end




mc.save_mail_string ""
mc.save_mail_string ""
conversations = helpscout.conversations(mailboxId,"pending", 0,"2016-01-01T00:00:00Z",nil)
if conversations.size > 0
    mc.save_mail_string "<br/><b>Pending: #{conversations.size}</b><br/>"
    conversations.each {|c| mc.print_conversation(c, print_status: false, print_created_at: true) }
end


def send_team_mail_message(title, message)
   begin
      RestClient.post "https://api:key"\
        "@api.mailgun.net/v3/mg.domain.example.com/messages",
        :from => "HelpScout<helpscout@mg.domain.example.com>",
        :to => "team@domain.example.com;boss@domain.example.com",
        :subject => title,
        :html => message
   rescue RestClient::ExceptionWithResponse => e
     puts e.response
   end
end

send_team_mail_message(title,mc.message)
