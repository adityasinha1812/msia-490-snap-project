from selenium import webdriver
from selenium.common.exceptions import WebDriverException
import chromedriver_binary
from bs4 import BeautifulSoup
import time
import random
from utils import save_file


class Crawler:
    def __init__(self, user, password):
        self.browser = webdriver.Chrome()
        self.user = user
        self.password = password

    def login(self):
        self.browser.get("https://www.linkedin.com/uas/login")

        username_input = self.browser.find_element_by_id('username')
        username_input.send_keys(self.user)

        password_input = self.browser.find_element_by_id('password')
        password_input.send_keys(self.password)
        password_input.submit()

    def visit_page(self, url):
        self.browser.get(url)
        # Scroll till the end of page
        self._scroll_down()

    def crawl_data(self, s_page=1, e_page=3):

        header = r'https://www.linkedin.com'
        search_page = r'https://www.linkedin.com/search/results/people/?facetNetwork=%5B%22F%22%5D' \
                      r'&origin=FACETED_SEARCH'
        info = {}

        for pi in range(s_page, e_page+1):
            outer_url = search_page + '&page=' + str(pi)
            c_obj.visit_page(outer_url)
            c_obj.random_wait()
            soup = BeautifulSoup(self.browser.page_source, 'html.parser')
            data = soup.find_all('div', {'class': 'search-result__wrapper'})
            print("Processing page: {}".format(pi))
            for div in data:
                # Get the user name and unique user link
                # This returns two sub-parts, we are only concerned with the second
                user = div.find_all('a', {'data-control-name': 'search_srp_result', 'href': True})[1]

                # Extract name and unique link of the user
                name = user.find('span', {'class': 'name actor-name'})
                link = user['href']

                # Get the shared connection link for that user
                shared_con = div.find('a', {'data-control-name': 'view_mutual_connections',
                                            'href': True})

                user_dict = {}
                if name and shared_con:
                    print("Processing user: {}".format(name.get_text()))
                    # Loop through all the pages
                    inner_pnum = 1
                    while True:
                        print("Processing Inner page: {}".format(inner_pnum))
                        url = header + shared_con['href'] + '&page=' + str(inner_pnum)
                        c_obj.visit_page(url)
                        c_obj.random_wait(s=5, e=30)
                        soup2 = BeautifulSoup(self.browser.page_source, 'html.parser')
                        temp_dict = c_obj._get_user_dict(soup2)

                        # Once the returned dict is empty, the crawler has reached the last page
                        if not temp_dict:
                            break

                        # Update the user_dict which will store info across all pages
                        user_dict.update(temp_dict)
                        inner_pnum += 1

                    # Add the combined info to top level dict
                    info[link] = [name.get_text(), user_dict]
                    print("----"*10)

            c_obj.random_wait()

        # Save the dict
        save_file(info, 'user_info_{}_{}'.format(s_page, e_page))

    @staticmethod
    def _get_user_dict(soup):
        """
        Crawls through the page and returns a dict of unique_url -> name

        Args:
            soup (soup obj): The current soup object containing html info

        Returns (dict): Dict of unique_url -> name
        """
        info = {}
        data = soup.find_all('div', {'class': 'search-result__wrapper'})
        for div in data:
            # Get the user name and unique user link
            # This returns two sub-parts, we are only concerned with the second
            user = div.find_all('a', {'data-control-name': 'search_srp_result', 'href': True})[1]

            # Extract name and unique link of the user
            name = user.find('span', {'class': 'name actor-name'})
            link = user['href']
            if name:
                # If shared connections exist, grab them too
                info[link] = name.get_text()

        return info

    def _scroll_down(self):
        """
        A method for scrolling the page.
        Credits: Ratmir Asanov
        """

        # Get scroll height.
        last_height = self.browser.execute_script("return document.body.scrollHeight")

        while True:
            # Scroll down to the bottom.
            # self.browser.execute_script("window.scrollTo(0, document.body.scrollHeight);")
            self.browser.execute_script("window.scrollTo({ top: document.body.scrollHeight, "
                                        "behavior: 'smooth' });")

            # Wait to load the page.
            self.random_wait()

            # Calculate new scroll height and compare with last scroll height.
            new_height = self.browser.execute_script("return document.body.scrollHeight")

            if new_height == last_height:
                break

            last_height = new_height

    @staticmethod
    def random_wait(s=2, e=6):
        """
        To reduce bot-like behavior, add random lag
        """
        time.sleep(random.randint(s, e))


if __name__ == '__main__':
    user = input("Enter user: ")
    password = input("Enter password: ")
    c_obj = Crawler(user, password)
    c_obj.login()
    c_obj.random_wait()
    c_obj.crawl_data(s_page=8, e_page=10)
