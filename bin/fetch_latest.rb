#! /usr/bin/env ruby

require 'bundler/setup'
Bundler.require

Capybara.default_driver = :poltergeist

class Main
  require 'capybara/dsl'
  include Capybara::DSL

  def main
    username = ENV['RAKUTEN_USERNAME']
    password = ENV['RAKUTEN_PASSWORD'] || get_password('Rakuten Password')
    login(username, password)

    open_invoices_tab

    transactions = extract_transactions
    transactions.each do |transaction|
      p transaction
    end
  end

  private

  def login(username, password)
    visit('http://rakuten-card.co.jp')
    within('#membersNaviSection .login') do
      click_link('楽天e-NAVIへログイン')
    end
    find('#indexForm')
    within('#indexForm') do
      fill_in 'u', with: username
      fill_in 'p', with: password
      click_button 'ログイン'
    end
  end

  def open_invoices_tab
    click_link('ご利用明細', match: :first)
  end

  def extract_transactions
    [].tap do |transactions|
      within('#latestSortForm table tbody') do
        extract_transactions_from_tr_elements(transactions)
      end

      within('#nextLatestSortForm table tbody') do
        extract_transactions_from_tr_elements(transactions)
      end if first('#nextLatestSortForm')
    end
  end

  def extract_transactions_from_tr_elements(transactions)
    all('tr').each do |element|
      cells = element.all('td').map(&:text)
      transactions << cells[0, 5]
    end
  end

  def get_password(prompt = 'Password')
    require 'io/console'
    STDOUT.print "Enter #{prompt}: "
    STDOUT.flush
    STDIN.noecho(&:gets)
  ensure
    STDOUT.puts
  end
end

Main.new.main
