from io import StringIO
from joblib import Parallel, delayed
import numpy as np
import pandas as pd
from playwright.sync_api import sync_playwright, Playwright
import re

pbp_links = pd.read_csv("data/game_pbp_links.csv")

def pbp_getter(link):
  
  results = []
  
  pw = sync_playwright().start()

  chrome = pw.chromium.launch(headless=True)

  page = chrome.new_page()

  try:
      page.goto(link)

      quarter_button_count = page.locator("css=.Button--unstyled.tabs__link").count()

      quarter_tables = []

      for quarter in range(quarter_button_count):
          page.locator("css=.Button--unstyled.tabs__link").nth(quarter).click()

          row_count = page.locator("css=.playByPlay__tableRow").count()

          period_results = []

          period = quarter + 1

          for row in range(row_count):
              time = page.locator(
                  "css=.playByPlay__tableRow"
              ).nth(row).locator('css=.playByPlay__time.Table__TD').inner_html()

              logo = page.locator(
                  "css=.playByPlay__tableRow"
              ).nth(row).locator('css=.playByPlay__logo.Table__TD').inner_html()

              play = page.locator(
                  "css=.playByPlay__tableRow"
              ).nth(row).locator('css=.playByPlay__text.tl.Table__TD').inner_html()

              away_score = page.locator(
                  "css=.playByPlay__tableRow"
              ).nth(row).locator('css=.playByPlay__score.playByPlay__score--away.tr.Table__TD').inner_html()

              home_score = page.locator(
                  "css=.playByPlay__tableRow"
              ).nth(row).locator('css=.playByPlay__score.playByPlay__score--home.tr.Table__TD').inner_html()

              output = pd.DataFrame(
                  {'time': [time], 'logo': [logo], 'play': [play],
                  'away_score': [away_score], 'home_score': [home_score], 'period': [period]}
              )

              period_results.append(output)

          period_results = pd.concat(period_results)

          quarter_tables.append(period_results)

      quarter_tables = pd.concat(quarter_tables)

      results.append(quarter_tables)

        # print('success')

  except Exception as e:
      print("An error occurred:", e)
      results.append(pd.DataFrame())

  results = pd.concat(results)
  
  results['link'] = link
  
  chrome.close()

  pw.stop()
  
  return results


pbp_getter(pbp_links['game_pbp_links'][2])

results = Parallel(n_jobs=10)(delayed(pbp_getter)(i) for i in pbp_links['game_pbp_links'])

results_concat = pd.concat(results)

results_concat.to_csv("data/all_nba_pbp_data.csv", index = False)

# Sequential processing below:

results = []

pw = sync_playwright().start()

chrome = pw.chromium.launch(headless=True)

page = chrome.new_page()

for link in pbp_links['game_pbp_links']:
    try:
        page.goto(link)

        quarter_button_count = page.locator("css=.Button--unstyled.tabs__link").count()

        quarter_tables = []

        for quarter in range(quarter_button_count):
            page.locator("css=.Button--unstyled.tabs__link").nth(quarter).click()

            row_count = page.locator("css=.playByPlay__tableRow").count()

            period_results = []

            period = quarter + 1

            for row in range(row_count):
                time = page.locator(
                    "css=.playByPlay__tableRow"
                ).nth(row).locator('css=.playByPlay__time.Table__TD').inner_html()

                logo = page.locator(
                    "css=.playByPlay__tableRow"
                ).nth(row).locator('css=.playByPlay__logo.Table__TD').inner_html()

                play = page.locator(
                    "css=.playByPlay__tableRow"
                ).nth(row).locator('css=.playByPlay__text.tl.Table__TD').inner_html()

                away_score = page.locator(
                    "css=.playByPlay__tableRow"
                ).nth(row).locator('css=.playByPlay__score.playByPlay__score--away.tr.Table__TD').inner_html()

                home_score = page.locator(
                    "css=.playByPlay__tableRow"
                ).nth(row).locator('css=.playByPlay__score.playByPlay__score--home.tr.Table__TD').inner_html()

                output = pd.DataFrame(
                    {'time': [time], 'logo': [logo], 'play': [play],
                    'away_score': [away_score], 'home_score': [home_score], 'period': [period]}
                )

                period_results.append(output)

            period_results = pd.concat(period_results)

            quarter_tables.append(period_results)

        quarter_tables = pd.concat(quarter_tables)

        results.append(quarter_tables)

        # print('success')

    except Exception as e:
        print("An error occurred:", e)
        results.append(pd.DataFrame())

results = pd.concat(results)

results.to_csv("all_nba_pbp_data.csv", index = False)

chrome.close()

pw.stop()
