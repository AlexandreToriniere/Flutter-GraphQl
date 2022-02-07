import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  final HttpLink httpLink = HttpLink("https://demo.saleor.io/graphql/");
  final ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      // The default store is the InMemoryStore, which does NOT persist to disk
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  var app = GraphQLProvider(client: client, child: MyApp());
  runApp(app);
}

const productGraphql = """
                    {
  products(first: 5, channel: "default-channel") {
    edges {
      node {
        id
        name
        description
        thumbnail{url}
      }
    }
  }
}
                  """;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Test E-Commerce GraphQL Client"),
        backgroundColor: Color.fromARGB(255, 99, 9, 9),
      ),
      body: Query(
        options: QueryOptions(document: gql(productGraphql)),
        builder: (QueryResult result, {fetchMore, refetch}) {
          if (result.hasException) {
            ;
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final producList = result.data?['products']['edges'];

          return Column(children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Products",
                  style: Theme.of(context).textTheme.headline5),
            ),
            Expanded(
              child: GridView.builder(
                  itemCount: producList.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2.0,
                    crossAxisSpacing: 2.0,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (_, index) {
                    var product = producList[index]['node'];

                    return Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(2.0),
                          width: 180,
                          height: 180,
                          child: Image.network(product['thumbnail']['url']),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(product['name']),
                        )
                      ],
                    );
                  }),
            )
          ]);
        },
      ),
    );
  }
}
