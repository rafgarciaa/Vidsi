require 'sqlite3'
require 'singleton'

class VidsiDBConnection < SQLite3::Database
    include Singleton

    def initialize
        super('vidsi.db')
        self.type_translation = true
        self.results_as_hash = true
    end
end

class Vidsi
    # SQL Query that returns the top 20 video/user pairings.
    # Show which videos have been most re-watched by a single user.
    def self.get_user_video_view_count
        # return value will be an array of hashes
        VidsiDBConnection.instance.execute(<<-SQL)
            SELECT first_name || ' '  || last_name AS name, title, COUNT(*) num_views
            FROM subscribers
                INNER JOIN views
                    ON views.subscriber_id = subscribers.id
                INNER JOIN videos
                    ON videos.id = views.video_id
            GROUP BY name, title
            ORDER BY num_views DESC
            LIMIT 20
        SQL
    end

    # Algorithm: find subscribers who haven't paid their invoices and need to be sent a cancellation notice.
    def self.get_unpaid_subscribers
        # return value w
        unpaid_subscribers = VidsiDBConnection.instance.execute(<<-SQL)
            SELECT first_name || ' '  || last_name AS name, email, SUM(invoices.amount_due - invoices.amount_paid) AS amount_owed
            FROM subscribers
                INNER JOIN invoices
                    ON invoices.subscriber_id = subscribers.id
            WHERE invoices.amount_due - invoices.amount_paid != 0
            GROUP BY subscribers.id
        SQL

        unpaid_subscribers.each do |subscriber|
            send_cancellation_notice(subscriber['email'])
        end
    end

    def self.send_cancellation_notice(subscriber_email)
        # code that sends cancellation notice to the given email
    end
end

puts '~~~~~~~~~~~~ SQL Query ~~~~~~~~~~~~'
puts Vidsi.get_user_video_view_count
puts '~~~~~~~~~~~~ Algorithm ~~~~~~~~~~~~'
puts Vidsi.get_unpaid_subscribers