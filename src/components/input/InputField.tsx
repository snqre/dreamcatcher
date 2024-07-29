import type { ReactNode } from "react";
import type { EventSubscription } from "@events-handler";
import type { ColProps } from "@layout/Col";
import { SubmitButton } from "@components/buttons/_/SubmitButton";
import { TextInput } from "./TextInput";
import { Row } from "@layout/Row";
import { Col } from "@layout/Col";
import { Text } from "@text/Text";
import { useState } from "react";
import { useEffect } from "react";
import { emit } from "@events-handler";
import { hook } from "@events-handler";

type InputFieldProps = 
    ColProps & {
    at: string;
    caption: string;
}

function InputField(props: InputFieldProps): ReactNode {
    let { at, caption, $style: style, ... more } = props;
    let [input, setInput] = useState<string>("");

    useEffect(function(): () => void {
        let subscriptions: EventSubscription[] = [
            hook({
                at: `${at}.submitButton`,
                type: "submission",
                handler: function(): void {
                    return emit({
                        from: at,
                        type: "submission",
                        item: input
                    });
                }
            }),
            hook({
                at: `${at}.input`,
                type: "input",
                handler: function(item?: unknown): void {
                    if (typeof item != "string") {
                        return;
                    }
                    return setInput(item);
                }
            })
        ];
        return function(): void {
            return subscriptions.forEach(subscription => subscription.remove());
        }
    }, [input]);

    return (
        <Col
        style={{
            width: "400px",
            height: "50px",
            alignItems: "start",
            ... style ?? {}
        }}
        { ... more }>
            <Text
            text={ caption }
            style={{
                fontSize: "0.75em",
                marginBottom: "5px",
                background: "#353535"
            }}/>
            <Row
            style={{
                width: "400px",
                height: "40px",
                borderWidth: "1px",
                borderColor: "#353535",
                borderStyle: "solid",
                justifyContent: "space-between"
            }}>
                <TextInput
                at={ `${at}.input` }
                $style={{
                    width: "360px",
                    height: "40px",
                    padding: "10px"
                }}/>
            </Row>
        </Col>
    );
}

export type { InputFieldProps };
export { InputField };