import SwiftUI

struct StartAppView: View {
    @Environment(AppViewModel.self) var appVM
    @State private var vm = StartAppViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("ユーザー名") {
                    TextField("名前を入力してください", text: $vm.userName)
                        .textInputAutocapitalization(.never)
                }

                Section("グループ") {
                    if vm.groups.isEmpty {
                        ProgressView("グループを読み込み中...")
                    } else {
                        Picker("グループを選択", selection: $vm.selectedGroupIndex) {
                            ForEach(vm.groups.indices, id: \.self) { i in
                                Text(vm.groups[i].displayName).tag(i)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                    NavigationLink("グループを新規作成") {
                        AddGroupView()
                            .navigationTitle("グループ作成")
                    }
                }

                Button("はじめる") {
                    vm.completeSetup(appVM: appVM)
                }
                .disabled(vm.userName.isEmpty || vm.groups.isEmpty)
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .navigationTitle("セットアップ")
            .onAppear { vm.fetchGroups() }
        }
    }
}
