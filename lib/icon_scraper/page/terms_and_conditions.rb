# frozen_string_literal: true

module IconScraper
  module Page
    # The page which pops annoyingly for you to agree to some arbitrary terms and conditions
    module TermsAndConditions
      def self.agree(doc, agent)
        button = agree_button(doc)
        raise "Can't find agree button" if button.nil?

        # If there's a checkbox, check it
        doc.form.checkbox_with(name: /Agree/)&.check

        # Do this hacky workaround for the benefit of boroondara
        # In their case the form submission does a redirect to an
        # http url which doesn't redirect to https. So, the whole
        # thing hangs. So, just disable redirects for this form
        # submission

        agent.redirect_ok = false
        a = doc.form.submit(button)
        agent.redirect_ok = true
        a
      end

      # See if we're actually on this page
      def self.on?(doc)
        !agree_button(doc).nil?
      end

      def self.agree_button(doc)
        doc.form.button_with(value: /Agree/)
      end
    end
  end
end
