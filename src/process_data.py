from utils import load_file, save_file
from constants import DATA_PATH
import pandas as pd
import os
from datetime import date, datetime
import numpy as np
from fuzzywuzzy import fuzz



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


def generate_adjacency_matrix():
    df_pre = pd.read_csv(DATA_PATH / 'edges_pre.csv')
    df_post = pd.read_csv(DATA_PATH / 'edges_all.csv')

    adj_mat_pre = np.zeros((1505, 1505), dtype=np.int32)
    adj_mat_post = np.zeros((1505, 1505), dtype=np.int32)

    # Generate the matrix for pre-covid data
    for index, row in df_pre.iterrows():
        i, j = row['ID1']-1, row['ID2']-1
        adj_mat_pre[i, j] = 1
        adj_mat_pre[j, i] = 1

    # Generate for post-covid data
    for index, row in df_post.iterrows():
        i, j = row['ID1']-1, row['ID2']-1
        adj_mat_post[i, j] = 1
        adj_mat_post[j, i] = 1

    # Save to disk
    np.savetxt(DATA_PATH / 'adj_pre.dat', X=adj_mat_pre, fmt='%i')
    np.savetxt(DATA_PATH / 'adj_post.dat', X=adj_mat_post, fmt='%i')


def generate_effects_companies():
    df = pd.read_csv(DATA_PATH / 'combined_data.csv')
    companies = df.set_index('ID')['Company'].to_dict()
    NUM_NODES = 1505
    nu_count = 0
    nu_feature = np.zeros(NUM_NODES+1, dtype=np.int32)  # 1 = if belongs to Northwestern,
    # 0 otherwise

    desired = "Northwestern"

    for k, v in companies.items():
        if type(v) == str:
            ratio = fuzz.partial_ratio(desired, v)
            if ratio > 90:
                nu_feature[k] = 1

    # Write feature to disk
    with open(DATA_PATH / 'nu.dat', 'w') as f:
        for index, val in enumerate(nu_feature):
            if index > 0:
                f.write("{} {}\n".format(val, val))

    f.close()


def generate_effects_positions(position):
    df = pd.read_csv(DATA_PATH / 'combined_data.csv')
    positions = df.set_index('ID')['Position'].to_dict()
    NUM_NODES = 1505
    pos_feature = np.zeros(NUM_NODES+1, dtype=np.int32)  # 1 = if = position else 0

    for k, v in positions.items():
        if type(v) == str:
            ratio = fuzz.partial_ratio(position, v)
            if ratio > 90:
                pos_feature[k] = 1

    # Write feature to disk
    file_name = position + ".dat"
    with open(DATA_PATH / file_name, 'w') as f:
        for index, val in enumerate(pos_feature):
            if index > 0:
                f.write("{} {}\n".format(val, val))

    f.close()


def generate_base_node_attr():
    df_pre = pd.read_csv(DATA_PATH / 'edges_pre.csv')
    df_post = pd.read_csv(DATA_PATH / 'edges_all.csv')
    NUM_NODES = 1505
    adj_mat_pre = np.zeros((NUM_NODES+1, NUM_NODES+1), dtype=np.int32)
    adj_mat_post = np.zeros((NUM_NODES+1, NUM_NODES+1), dtype=np.int32)

    # Generate the matrix for pre-covid data
    for index, row in df_pre.iterrows():
        i, j = row['ID1'], row['ID2']
        adj_mat_pre[i, j] = 1
        adj_mat_pre[j, i] = 1

    # Generate for post-covid data
    for index, row in df_post.iterrows():
        i, j = row['ID1'], row['ID2']
        adj_mat_post[i, j] = 1
        adj_mat_post[j, i] = 1

    # Now, label nodes based on which base nodes they are connected to
    # 'Omkar': 1, 'Aditya': 2, 'Amisha': 3, 'Anuradha': 4, Mutual: 5, Base node itself: 0
    base_nodes = [1, 2, 3, 4]
    labels_pre = np.zeros(NUM_NODES+1, dtype=np.int32)
    labels_post = np.zeros(NUM_NODES+1, dtype=np.int32)

    for i in range(NUM_NODES+1):
        for bn in base_nodes:
            if adj_mat_pre[bn, i] == 1:
                labels_pre[i] = bn if labels_pre[i] == 0 else 5

            if adj_mat_post[bn, i] == 1:
                labels_post[i] = bn if labels_post[i] == 0 else 5

    print(labels_pre, labels_post)

    mutual_in_pre = np.where(labels_pre == 5)[0]
    mutual_in_post = np.where(labels_post == 5)[0]

    print("Mutual connections went up from {} to {}".format(len(mutual_in_pre), len(mutual_in_post)))
    # Write feature to disk
    file_name = "base_node_feature.dat"
    with open(DATA_PATH / file_name, 'w') as f:
        for i in range(len(labels_pre)):
            if i > 0:
                f.write("{} {}\n".format(labels_pre[i], labels_post[i]))

    f.close()


if __name__ == '__main__':
    # combine_data()
    # generate_edges(filter_date='2020-3-31')

    # generate_adjacency_matrix()
    # generate_effects_companies()
    # generate_effects_positions(position="Engineer")
    # generate_effects_positions(position="Research")
    # generate_effects_positions(position="Manager")
    # generate_effects_positions(position="Director")

    generate_base_node_attr()