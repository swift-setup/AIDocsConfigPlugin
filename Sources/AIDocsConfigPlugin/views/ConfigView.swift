//
//  SwiftUIView.swift
//
//
//  Created by Qiwei Li on 6/12/23.
//

import SwiftUI
import SwiftUIJsonSchemaForm

struct ConfigView: View {
    @EnvironmentObject var model: AIDocsConfigModel

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Reload") {
                    Task {
                        await model.fetch()
                    }
                }
            }
            Spacer()
            if model.isLoading {
                ProgressView()
            } else {
                if let values = model.values, let schema = model.schema {
                    SwiftUIJsonSchemaForm.FormView(jsonSchema: schema, values: values) { newValues in
                        model.values = newValues
                        model.saved = false
                    }
                }
            }

            if !model.isLoading {
                HStack {
                    Spacer()
                    Button {
                        Task {
                            await model.save()
                        }
                    } label: {
                        if model.saved {
                            Image(systemName: "checkmark")
                                .foregroundColor(.green)
                                .frame(width: 50.0, height: 20.0)

                        } else if model.saving {
                            ProgressView()
                        } else {
                            Text("Save")
                                .frame(width: 50.0, height: 20.0)
                        }
                    }
                    .disabled(model.saved)
                }
            }

            Spacer()
        }
    }
}
