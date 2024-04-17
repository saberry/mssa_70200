from io import StringIO
import numpy as np
import pandas as pd
from playwright.sync_api import sync_playwright, Playwright
import re

pbp_links = pd.read_csv("data/game_pbp_links.csv")

results = [] * pbp_links['game_pbp_links'].size

pw = sync_playwright().start()

chrome = pw.chromium.launch(headless=True)

page = chrome.new_page()

for link in pbp_links['game_pbp_links'].loc[1:2]:
  try:
    print(link)
    page.goto(link)

    quarter_button_count = page.locator("css=.Button--unstyled.tabs__link").count()

    quarter_tables = [] * quarter_button_count

    page.locator(
      "css=.playByPlay__logo.Table__TD img.Image.Logo.Logo__sm"
      ).all()[0].get_attribute("src")
      
    print(quarter_button_count)

    for quarter in range(quarter_button_count):
      page.locator("css=.Button--unstyled.tabs__link").nth(quarter).click()
      quarter_read = pd.read_html(StringIO(page.inner_html("*")), match="PLAY")[0]
      quarter_read['quarter'] = quarter + 1
      logo_counter = page.locator(
      "css=.playByPlay__logo.Table__TD img.Image.Logo.Logo__sm"
      ).count()

      if quarter < 3:
        logo_container = np.empty(shape=logo_counter + 1, dtype=object)
      else:
        logo_container = np.empty(shape=logo_counter + 2, dtype=object)

      for logo in range(logo_counter):
        logos = page.locator(
          "css=.playByPlay__logo.Table__TD img.Image.Logo.Logo__sm"
          ).all()[logo].get_attribute("src")
        logo_container[logo] = logos

      if quarter < 3:
        logo_container[logo+1] = np.nan
      else:
        logo_container[logo+1] = np.nan
        logo_container[logo+2] = np.nan

      quarter_read['logo'] = logo_container

      quarter_tables.append(quarter_read)

    quarter_tables = pd.concat(quarter_tables)

    quarter_tables['team'] = quarter_tables['logo'].str.extract(
      r'([a-z]{3}(?=.png))'
      )
      
    print(quarter_tables['team'])

    results.append(quarter_tables)
    print('success')
    
  except:   
    print("fail")
    results.append(pd.DataFrame())

chrome.close()

pw.stop()
