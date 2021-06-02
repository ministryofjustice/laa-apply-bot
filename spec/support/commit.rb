# rubocop:disable Layout/LineLength, Metrics/MethodLength
def load_shared_commit_data
  let(:commits) do
    [
      { 'sha': '123456', 'url': '123456', 'commit': { 'message': "Merge pull request #1999 from moj/AA-1234\n\nImprove something important" } },
      { 'sha': '234567', 'url': '234567', 'commit': { 'message': "Merge pull request #1998 from moj/AA-421\n\nMinor tweak to something" } },
      { 'sha': '345678', 'url': '345678', 'commit': { 'message': "Improve the thing\n\nSo that the other thing looks better" } },
      { 'sha': '456789', 'url': '456789', 'commit': { 'message': "Tweak the layout of results\n\nShould have been left aligned" } },
      { 'sha': '678912', 'url': '678912', 'commit': { 'message': "Merge pull request #1997 from moj/AA-666\n\nMade everything shiny" } },
      { 'sha': '789123', 'url': '789123', 'commit': { 'message': "Merge pull request #1996 from moj/AA-555\n\nMade everything dull" } },
      { 'sha': '891234', 'url': '891234', 'commit': { 'message': "Merge pull request #1995 from moj/AA-444\n\nMade everything work" } },
      { 'sha': '912345', 'url': '912345', 'commit': { 'message': "Merge pull request #1994 from moj/AA-333\n\nMade some stuff work" } }
    ].to_json
  end
end
# rubocop:enable Layout/LineLength, Metrics/MethodLength
