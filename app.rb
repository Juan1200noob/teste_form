require "rack"
require "dotenv/load"
require "sinatra"
require "mail"

set :bind, '0.0.0.0'
set :port, ENV['PORT'] || 4567

get "/" do
  redirect "/home"
end

get "/home" do
    erb :index
end

post "/contact" do
    email = params["email"].to_s.strip
    mensagem = params["message"].to_s.strip

    sanitized_email = email.gsub(/[\r\n]+/, " ").strip

    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

    unless sanitized_email =~ email_regex
        halt 400, "Email inválido!"
    end

    halt 400, "Mensagem muito longa!" if mensagem.size > 1000

    safe_email = Rack::Utils.escape_html(sanitized_email)
    safe_mensagem = Rack::Utils.escape_html(mensagem)

    Mail.defaults do
        delivery_method :smtp, {
            address: "smtp.sendgrid.net",
            port: 587,
            domain: "teste-form.onrender.com",
            user_name: "apikey",
            password: ENV["USER_PASSWORD"],
            authentication: "plain",
            enable_starttls_auto: true
        }
    end

    mail = Mail.new do
        from   ENV["USER_NAME"]
        to     ENV["USER_NAME"]
        subject      "Contato"
        html_part do
            content_type 'text/html; charset=UTF-8'
            body "<strong>Email: #{safe_email}</strong><br><strong>Mensagem: <br>#{safe_mensagem}</strong>"
        end
    end

    mail.deliver!

    erb :contact
end