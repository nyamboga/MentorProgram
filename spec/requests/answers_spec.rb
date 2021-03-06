require 'spec_helper'

describe "Answers" do

  describe "answering a mentoring request" do
    let!(:ask) { FactoryGirl.create(:mentor_ask) }
    before do
      visit mentors_sign_up_path
      click_link 'answer_ask_1'
    end

    it "should take me to the new answer page" do
      expect(page).to have_selector "p#become_mentor"
    end
    describe "and filling out the form" do
      context "with valid information" do
        before do
          fill_in "Name", with: "the answerer"
          fill_in "email address", with: "answerer@example.com"
          check "answer_disclaimer"
        end

        it "should create a new answer" do
          expect { click_button "Go! »"}.to change(Answer, :count).by(1)
        end
        it "should mark the mentee request as answered" do
          click_button "Go! »"
          ask.reload
          expect(ask.answered?).to be_true
        end
        it "should redirect to the mentors thank you page" do
          click_button "Go! »"
          expect(page).to have_selector "h1#thank_you"
        end
        context "and then trying to reanswer the request" do
          before do
            click_button "Go! »"
            @original_answer = ask.answer
            visit new_answer_path({ask_id: ask.id})
            fill_in "Name", with: "the answerer2"
            fill_in "email address", with: "answerer2@example.com"
            click_button "Go! »"
          end

          it "should not replace the existing answer" do
            expect(ask.answer).to eq @original_answer
          end
          it "should redirect to the homepage" do
            expect(page).to have_selector "h1", "Mentor Program"
          end
        end
      end
      context "without agreeing to disclaimer" do
        it "should rerender the form" do
          click_button "Go! »"
          expect(page).to have_selector "p#become_mentor"
        end
        it "should display a message about why information ws not valid" do
          click_button "Go! »"
        end
      end
      context "with invalid information" do
        it "should rerender the form" do
          click_button "Go! »"
          expect(page).to have_selector "p#become_mentor"
        end
        it "should display a message about why information ws not valid" do
          click_button "Go! »"
          expect(page).to have_selector 'div.error_explanation'
        end
        it "should not create a new answer" do
          expect { click_button "Go! »"}.to_not change(Answer, :count)
        end
      end
    end
  end

  describe "answering a pairing request" do
    let!(:ask) { FactoryGirl.create(:pair_ask) }
    before do
      visit pair_asks_path
      click_link 'answer_ask_1'
      fill_in "Name", with: "the answerer"
      fill_in "email address", with: "answerer@example.com"
      check "answer_disclaimer"
    end

    describe "with valid information" do
      it "should redirect to the pair response thank you page" do
        click_button "Go! »"
        expect(page).to have_selector "h1#thank_you"
      end
    end
  end


  describe "answered mentee requests" do
    it "are not present" do
      answered_mentee = FactoryGirl.create(:ask)
      answered_mentee.answered = true
      answered_mentee.save
      visit mentors_sign_up_path
      expect(page).to_not have_selector "tr#ask_#{answered_mentee.id}"
    end
  end

end
