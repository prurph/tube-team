###TubeTeam is fantasy sports but with youtube Videos!

Playing is easy and largely self explanatory. Basic steps:

- Sign up and log in
- Search for videos (using either the magnifying glass icon on the home page,
your team page, or by clicking [Your Team Name] in the nav header)
- Videos can be searched using general terms ("puppies"), which will return the
top six results, or by pasting in a specific YouTube URL. The URL can be any
format (directly from youtube, using the embed link as in http://youtu.be/...,
etc.)
- Sign videos from the search results by clicking the green checkbox icon. Each
video can only be on a single team.
- Points are scored as the video is viewed! Data is from the YouTube API so views
anywhere on the internet count toward your total.
- The current implementation is that one view = one point regardless of video,
but as we collect more data this will be skewed so that more popular videos
yield fractionally fewer points per additional view.
- Teams have a maximum of five videos, and each team has a starting bankroll of
10MM, so the aggregate total of your videos' initial views cannot exceed that.
- Videos can be dropped at any time, and any views they have accrued while on
your squad will stick with the team.

##Have fun!
