from utils import load_file, save_file
from constants import DATA_PATH
import pandas as pd
import os
from datetime import date, datetime


def combine_data():
    """
    Combine the data across all files and save it as a single csv file.
    Two dictionaries are also generated of the following key -> value pair :
    name (First Name + Last Name) ->  numeric id
    name (First Name + Last Name -> connected date
    """
    df_combined = pd.DataFrame(columns=['ID', 'First Name', 'Last Name', 'Full Name', 'Company',
                                        'Position',
                                        'Connected On'])
    #
    # name_to_id = {'Omkar Ranadive': 1, 'Aditya Sinha': 2, 'Amisha Agarwal': 3, 'Anuradha Boche': 4,
    #               'Nikhil Thakurdesai': 5, 'Anupam Tripathi': 6}

    name_to_id = {'Omkar Ranadive': 1, 'Aditya Sinha': 2, 'Amisha Agarwal': 3, 'Anuradha Boche': 4,
                 }

    counter = max(name_to_id.values()) + 1

    for folder in os.listdir(DATA_PATH):
        if os.path.isdir(DATA_PATH / folder):
            inner_folder = DATA_PATH / folder
            print("Processing folder: {}".format(inner_folder))
            name_to_date = {}
            for file in os.listdir(inner_folder):
                if file[-3:] == 'csv':
                    df_cur = pd.read_csv(inner_folder / file)
                    # Convert connected on column to date time
                    df_cur['Connected On'] = pd.to_datetime(df_cur['Connected On'])
                    # Drop the email column
                    df_cur = df_cur.drop(['Email Address'], axis=1)
                    # Assign unique ids
                    ids = []
                    names = []
                    for index, row in df_cur.iterrows():
                        # Assumption: First name + last name combinations are unique
                        name = str(row['First Name']) + " " + str(row['Last Name'])
                        con_date = row['Connected On']
                        names.append(name)
                        name_to_date[name] = con_date
                        if name in name_to_id:
                            ids.append(name_to_id[name])
                        else:
                            name_to_id[name] = counter
                            ids.append(counter)
                            counter += 1

                    assert len(ids) == len(df_cur), "Number of ids generated != number of people"
                    df_cur['ID'] = ids
                    df_cur['Full Name'] = names

                    # Append to global dataframe
                    df_combined = pd.concat([df_combined, df_cur])

                    # Name_to_date should be unique to each user
                    save_file(name_to_date, 'name_to_date', path=inner_folder)

        # Save the files
        df_combined.to_csv(DATA_PATH / 'combined_data.csv', index=False)
        save_file(name_to_id, 'name_to_id')


def generate_edges(filter_date):
    """
    Generate edges a -> b for all nodes and save them to a file. Three files are generated:
    1. Edges which existed before filter date
    2. Edges which existed after filter date
    3. All edges together
    Args:
        filter_date (str): Date in %Y%M%D string format
    """
    name_to_id = load_file('name_to_id')
    main_fold_dict = {'Omkar': 1, 'Aditya': 2, 'Amisha': 3, 'Anuradha': 4, }

    fdate = datetime.strptime(filter_date, '%Y-%m-%d')  # Convert to datetime object
    edges_all = {}
    edges_pre = {}
    edges_post = {}

    for folder in os.listdir(DATA_PATH):
        if os.path.isdir(DATA_PATH / folder):
            inner_folder = DATA_PATH / folder
            id1 = main_fold_dict[folder]
            print("Processing folder: {}".format(inner_folder))
            for file in os.listdir(inner_folder):
                if file[-3:] == 'csv':
                    df_cur = pd.read_csv(inner_folder / file)
                    df_cur['Connected On'] = pd.to_datetime(df_cur['Connected On'])

                    for index, row in df_cur.iterrows():
                        name = str(row['First Name']) + " " + str(row['Last Name'])
                        con_date = row['Connected On']
                        # Frozenset ensures that (a, b) = (b, a) (undirected graph)
                        if name in name_to_id:
                            edges_all[frozenset((id1, name_to_id[name]))] = 1

                            if con_date <= fdate:
                                edges_pre[frozenset((id1, name_to_id[name]))] = 1
                            else:
                                edges_post[frozenset((id1, name_to_id[name]))] = 1

                elif file == 'Mutual':
                    name_to_date = load_file('name_to_date', inner_folder)
                    for uinfo in os.listdir(inner_folder / file):
                        cur_user = load_file(uinfo, path=inner_folder/file)

                        for k1, v1 in cur_user.items():
                            if v1[0] in name_to_id:
                                inner_id1 = name_to_id[v1[0]]
                                mutual_con_dict = v1[1]
                                for k2, v2 in mutual_con_dict.items():
                                    if v2 in name_to_id and v2 in name_to_date:
                                        inner_id2 = name_to_id[v2]
                                        edges_all[frozenset((inner_id1, inner_id2))] = 1
                                        con_date = name_to_date[v1[0]]
                                        if con_date <= fdate:
                                            edges_pre[frozenset((inner_id1, inner_id2))] = 1
                                        else:
                                            edges_post[frozenset((inner_id1, inner_id2))] = 1

    # Save the edge info to disk for all three cases
    # print(edges_all)
    save_edges(edges_all, 'edges_all.csv')
    save_edges(edges_pre, 'edges_pre.csv')
    save_edges(edges_post, 'edges_post.csv')


def save_edges(edges, filename):
    df_edges = pd.DataFrame(columns=['ID1', 'ID2'])  # Remember this is undirected

    ids_1, ids_2 = [], []
    for edge in edges.keys():
        a, b = tuple(edge)
        ids_1.append(a)
        ids_2.append(b)

    df_edges['ID1'] = ids_1
    df_edges['ID2'] = ids_2

    print("Number of edges generated: ", len(df_edges))

    df_edges.to_csv(DATA_PATH / filename, index=False)


if __name__ == '__main__':
    combine_data()
    generate_edges(filter_date='2020-3-31')
