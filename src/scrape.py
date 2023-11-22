from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import StaleElementReferenceException
from dotenv import load_dotenv

import time
import os

load_dotenv()


BASE_URL = os.getenv("BASE_URL")
SEARCH_QUERY = os.getenv("SEARCH_QUERY")

print(f"BASE_URL: {BASE_URL}")
print(f"SEARCH_QUERY: {SEARCH_QUERY}")

options = webdriver.ChromeOptions()
options.add_argument("--headless=new")
options.add_argument("--no-sandbox")
driver = webdriver.Chrome(options=options)
driver.get(BASE_URL)

wait = WebDriverWait(driver, 10)

wait.until(
    EC.element_to_be_clickable((By.ID, "newCookieDisclaimerButton"))
).click()

location_input = wait.until(
    EC.presence_of_element_located((By.XPATH, '//*[@id=":Rml5s:"]'))
)
location_input.send_keys(SEARCH_QUERY)
time.sleep(1.0)


address_element = wait.until(
    EC.element_to_be_clickable((By.XPATH, '//*[@id="LOCATION-list"]/li[1]'))
)
address_element.click()

wait.until(
    EC.element_to_be_clickable((By.XPATH, '//*[@id=":R355s:"]'))
).click()

total_pages_element = wait.until(
    EC.presence_of_element_located(
        (By.CLASS_NAME, "andes-pagination__page-count")
    )
)
total_pages = int(total_pages_element.text.split()[-1])

all_properties = []
actual_page = 0

while actual_page < total_pages:
    print(actual_page, total_pages)
    try:
        property_list = wait.until(
            EC.presence_of_all_elements_located(
                (By.CLASS_NAME, "ui-search-result")
            )
        )
        print(f"Properties in page {actual_page + 1}: {len(property_list)}")
        for property in property_list:
            property_link_element = property.find_element(By.TAG_NAME, "a")
            property_link = property_link_element.get_attribute("href")
            property_info = (
                property_link + ";" + property.text.replace(";", ",")
            )
            all_properties.append(property_info.replace("\n", " "))
        if actual_page < total_pages - 1:
            next_page_arrow = wait.until(
                EC.element_to_be_clickable(
                    (By.CSS_SELECTOR, "li.andes-pagination__button--next a")
                )
            )
            next_page_arrow.click()
        actual_page += 1
    except StaleElementReferenceException:
        print("Encountered a stale element, retrying...")
        continue  # This will retry the current page


filename = str(int(time.time()))
all_properties = list(set(all_properties))
print(f"Found {len(all_properties)} to save in filename {filename}")

with open(filename, mode="w") as file:
    file.write("\n".join(all_properties))

driver.quit()
