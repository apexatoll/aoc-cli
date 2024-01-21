RSpec.describe AocCli::Processors::ProgressSyncer do
  let(:now) { Time.now.round(6) }

  before { allow(Time).to receive(:now).and_return(now) }

  describe "#run!" do
    subject(:run!) { described_class.run!(puzzle:, stats:) }

    let(:event) { create(:event) }

    let(:puzzle) { create(:puzzle, event:) }

    let(:stats) do
      create(:stats, event:, "day_#{puzzle.day}": current_progress)
    end

    context "when puzzle and stats are present" do
      context "and puzzle is not complete" do
        let(:current_progress) { 0 }

        context "and part one progress record does not exist" do
          it "creates a part one progress record" do
            expect { run! }
              .to create_model(AocCli::Progress)
              .with_attributes(puzzle:, level: 1, started_at: now)
          end
        end

        context "and part one progress record exists" do
          let!(:part_one_progress) do
            create(:progress, :part_one, puzzle:, started_at:)
          end

          let(:started_at) { now - 5000 }

          it "does not create a progress record" do
            expect { run! }.not_to create_model(AocCli::Progress)
          end

          it "does not change the exsting progress record" do
            expect { run! }.not_to change { part_one_progress.reload.values }
          end
        end
      end

      context "and puzzle is partially complete" do
        let(:current_progress) { 1 }

        context "and part one progress record does not exist" do
          context "and part two progress record does not exist" do
            it "does not create a part one progress record" do
              expect { run! }
                .not_to create_model(AocCli::Progress)
                .with_attributes(puzzle:, level: 1)
            end

            it "creates a part two progress record" do
              expect { run! }
                .to create_model(AocCli::Progress)
                .with_attributes(puzzle:, level: 2, started_at: now)
            end
          end

          context "and part two progress record exists" do
            let!(:part_two_progress) { create(:progress, :part_two, puzzle:) }

            it "does not create a part one progress record" do
              expect { run! }
                .not_to create_model(AocCli::Progress)
                .with_attributes(puzzle:, level: 1)
            end

            it "does not create a part two progress record" do
              expect { run! }
                .not_to create_model(AocCli::Progress)
                .with_attributes(puzzle:, level: 2)
            end

            it "does not update the part two progress record" do
              expect { run! }.not_to change { part_two_progress.reload.values }
            end
          end
        end

        context "and part one progress record exists" do
          let!(:part_one_progress) do
            create(:progress, :part_one, puzzle:, completed_at:)
          end

          context "and part one progress is incomplete" do
            let(:completed_at) { nil }

            context "and part two progress record does not exist" do
              it "does not create a part one progress record" do
                expect { run! }
                  .not_to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 1)
              end

              it "marks part one as complete" do
                expect { run! }
                  .to change { part_one_progress.reload.complete? }
                  .from(false)
                  .to(true)
              end

              it "creates a part two progress record" do
                expect { run! }
                  .to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 2, started_at: now)
              end
            end

            context "and part two progress record exists" do
              let!(:part_two_progress) do
                create(:progress, :part_two, puzzle:)
              end

              it "does not create a part one progress record" do
                expect { run! }
                  .not_to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 1)
              end

              it "marks part one as complete" do
                expect { run! }
                  .to change { part_one_progress.reload.complete? }
                  .from(false)
                  .to(true)
              end

              it "does not create a part two progress record" do
                expect { run! }
                  .not_to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 2, started_at: now)
              end

              it "does not change part two progress" do
                expect { run! }
                  .not_to change { part_two_progress.reload.values }
              end
            end
          end

          context "and part one progress is complete" do
            let(:completed_at) { now - 5000 }

            context "and part two progress record does not exist" do
              it "does not create a part one progress record" do
                expect { run! }
                  .not_to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 1)
              end

              it "does not change part one progress" do
                expect { run! }
                  .not_to change { part_one_progress.reload.values }
              end

              it "creates a part two progress record" do
                expect { run! }
                  .to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 2, started_at: now)
              end
            end

            context "and part two progress record exists" do
              let!(:part_two_progress) do
                create(:progress, :part_two, puzzle:)
              end

              it "does not create a part one progress record" do
                expect { run! }
                  .not_to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 1)
              end

              it "does not change part one progress" do
                expect { run! }
                  .not_to change { part_one_progress.reload.values }
              end

              it "does not create a part two progress record" do
                expect { run! }
                  .not_to create_model(AocCli::Progress)
                  .with_attributes(puzzle:, level: 2)
              end

              it "does not change part two progress" do
                expect { run! }
                  .not_to change { part_two_progress.reload.values }
              end
            end
          end
        end
      end

      context "and puzzle is fully complete" do
        let(:current_progress) { 2 }

        context "and part two progress record does not exist" do
          it "does not create a part two progress record" do
            expect { run! }
              .not_to create_model(AocCli::Progress)
              .with_attributes(puzzle:, level: 2)
          end
        end

        context "and part two progress record exists" do
          let!(:part_two_progress) do
            create(:progress, :part_two, puzzle:, completed_at:)
          end

          context "and part two progress is incomplete" do
            let(:completed_at) { nil }

            it "does not create a part two progress record" do
              expect { run! }
                .not_to create_model(AocCli::Progress)
                .with_attributes(puzzle:, level: 2)
            end

            it "marks part two as complete" do
              expect { run! }
                .to change { part_two_progress.reload.complete? }
                .from(false)
                .to(true)
            end
          end

          context "and part two progress is complete" do
            let(:completed_at) { now - 5000 }

            it "does not create a part two progress record" do
              expect { run! }
                .not_to create_model(AocCli::Progress)
                .with_attributes(puzzle:, level: 2)
            end

            it "does not change part two progress" do
              expect { run! }
                .not_to change { part_two_progress.reload.values }
            end
          end
        end
      end
    end
  end
end
