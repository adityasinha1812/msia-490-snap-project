from constants import DATA_PATH
import pandas as pd
from datetime import date, datetime
import numpy as np


def calculate_con_increase(df_cur, sdate, edate):
    sdate = datetime.strptime(sdate, '%Y-%m-%d')
    edate = datetime.strptime(edate, '%Y-%m-%d')
    df_cur['Connected On'] = pd.to_datetime(df_cur['Connected On'])
    df_cur = df_cur[(df_cur['Connected On'] >= sdate)
                    & (df_cur['Connected On'] <= edate)]

    print("Connected to {} people in the range {} - {}".format(len(df_cur),
                                                               sdate, edate))


if __name__ == '__main__':
    aditya_con = pd.read_csv(DATA_PATH / 'Aditya' / 'Connections.csv')
    omkar_con = pd.read_csv(DATA_PATH / 'Omkar' / 'Connections.csv')
    anuradha_con = pd.read_csv(DATA_PATH / 'Anuradha' / 'Connections.csv')

    calculate_con_increase(aditya_con, sdate='2019-09-01', edate='2020-03-31')
    calculate_con_increase(anuradha_con, sdate='2019-09-01', edate='2020-03-31')
    calculate_con_increase(omkar_con, sdate='2019-09-01', edate='2020-03-31')

