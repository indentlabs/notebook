# Indent


## What is Indent?
see [live website](http://indentapp.com)

> Indent is a set of tools for writers, game designers, and roleplayers to create magnificent universes – and everything within them.

> From a simple interface in your browser, on your phone, or on your tablet, you can do everything you'd ever want to do while creating your own little (or big!) world.

Indent is a writer's planning tool for creating anything from universes to characters, to plots, to individual items.

It is also meant to expand into many areas to benefit writers, including areas like:

- Automated revision services
- Structuring real-time natural language processing output into a semantically reusable state
- Decision-making algorithms for improving reading comprehension, reading level, accent-correction, and other real-
 time writing suggestions
- A knowledge graph of structured data in your universe, and an engine to manipulate it in awesome ways
- Machine learning on generating character and location names, suggesting realistic defaults (random or not), and more
- and tons more


## The Issue Tracker

If you are interested in helping out, check out the issue tracker. I've loaded it with tons of action-based, chunk-sized improvements that I think anyone familiar with Rails will be able to jump in and complete. Feel free to make suggestions, open issues, join discussions, or ask where you should look in the code to get started implementing something. :)

You'll notice there are *a lot* of issues in *a lot* of milestones. Call it feature creep, but I've separated every potential idea for full-fledged services into milestones that can be worked on completely independently of others. The features are (for the most part) has no deadlines and are in development simultaneously, meaning if you see a feature you would really like to use, you can make that feature happen by jumping directly into it and completing its issues.

TL;DR Milestones are independent of each other -- work on whatever you want to see made!


## Installing the Indent stack locally (for development)

Install curl

    sudo apt-get install curl

Install rvm

    \curl -sSL https://get.rvm.io | bash
    source /home/drusepth/.rvm/scripts/rvm

Install ruby 1.9.3

    rvm install ruby 2.0.0

Install rails 4.0.1

    gem install rails

Install mongodb

    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

    echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list

    sudo apt-get update

    sudo apt-get install mongodb-10gen

Install gems

    bundle install

You can run the rails server with

    rails server


## Deployment to indentapp.com

Deployment to the live stage will only be done by approved developers, and consists of a deployment of

- deploy github to staging (done only by approved developers)

- mirror data from live into staging

- run regression tests on staging environment

- deploy from staging to live (viewed at indentapp.com)


## Thanks

Feel free to get in touch if you have any questions, comments, or concerns! :)
